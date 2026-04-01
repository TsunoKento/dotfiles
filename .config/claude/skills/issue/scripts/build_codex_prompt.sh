#!/usr/bin/env bash
# build_codex_prompt.sh — Fetch a GitHub issue, build a Codex prompt, and run it.
#
# Usage: bash build_codex_prompt.sh <issue-number>
#
# Must be run from inside the worktree directory for the issue.

set -euo pipefail

ISSUE_NUMBER="${1:?Usage: $0 <issue-number>}"

# Fetch issue content using --jq to safely handle special characters
ISSUE_TITLE=$(gh issue view "$ISSUE_NUMBER" --json title --jq '.title')
ISSUE_BODY=$(gh issue view "$ISSUE_NUMBER" --json body --jq '.body')

# Extract 達成基準 section (everything between ## 達成基準 and the next ## heading)
CRITERIA=$(printf '%s' "$ISSUE_BODY" | awk '/^## 達成基準/{found=1; next} found && /^## /{exit} found{print}')

# Extract 注釈 section (out-of-scope notes)
OUT_OF_SCOPE=$(printf '%s' "$ISSUE_BODY" | awk '/^## 注釈/{found=1; next} found && /^## /{exit} found{print}')

# Find the first available project conventions file
CONVENTIONS=""
for f in AGENTS.md CODEX.md CLAUDE.md; do
  if [ -f "$f" ]; then
    CONVENTIONS=$(cat "$f")
    break
  fi
done

# Build the prompt
PROMPT=$(printf 'Implement this GitHub issue. Do not run git commands or create commits.\n\nIssue: %s\n\n## 達成基準\n\n%s\n' "$ISSUE_TITLE" "$CRITERIA")

if [ -n "$CONVENTIONS" ]; then
  PROMPT=$(printf '%s\n\n## Project Conventions\n\n%s\n\n## Instructions\n- Implement every checklist item in 達成基準\n- Follow the project conventions above\n- Explore the codebase to understand context\n- Only modify files needed to satisfy the criteria\n- Do NOT implement anything beyond the 達成基準 checklist items above\n- Do NOT add endpoints, business logic, or features not explicitly listed\n- Do not commit\n' "$PROMPT" "$CONVENTIONS")
else
  PROMPT=$(printf '%s\n\n## Instructions\n- Implement every checklist item in 達成基準\n- Explore the codebase to understand context\n- Only modify files needed to satisfy the criteria\n- Do NOT implement anything beyond the 達成基準 checklist items above\n- Do NOT add endpoints, business logic, or features not explicitly listed\n- Do not commit\n' "$PROMPT")
fi

if [ -n "$OUT_OF_SCOPE" ]; then
  PROMPT=$(printf '%s\n\n## スコープ外（実装しないこと）\n\n%s\n' "$PROMPT" "$OUT_OF_SCOPE")
fi

# Write prompt to a temp file and invoke Codex
PROMPT_FILE="/tmp/codex_prompt_issue_${ISSUE_NUMBER}.txt"
printf '%s' "$PROMPT" > "$PROMPT_FILE"

echo "Running Codex for issue #${ISSUE_NUMBER}..."
OUTPUT=$(codex exec --sandbox workspace-write - < "$PROMPT_FILE" 2>&1)
EXIT=$?

echo "$OUTPUT"
exit $EXIT

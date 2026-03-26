---
name: issue
description: Create a GitHub Issue and a corresponding branch for issue-driven development
---

# Issue-Driven Development Skill

Create a GitHub Issue and check out a corresponding branch in one step.

## Branch Naming Convention

```
issue-{number}-{short-slug}
```

The slug is derived from the issue title: lowercase, spaces and special characters replaced with hyphens, trimmed to ~4 meaningful words.

### Examples

| Issue title | Branch |
|---|---|
| "Add web server setup" | `issue-1-web-server-setup` |
| "Fix auth bug in login" | `issue-42-fix-auth-bug` |
| "Add dark mode support" | `issue-7-add-dark-mode` |

## Instructions

When the user invokes `/issue`:

1. Check the current branch — confirm with the user if it doesn't look like an appropriate base (e.g., already on a feature branch)
2. Collect issue details:
   - If `$ARGUMENTS` is provided, use it as the issue title. Otherwise ask for the title.
   - Based on the title (and any context from `$ARGUMENTS`), draft the full issue body using this template:
     ```
     ## 背景

     {inferred background / problem statement}

     ## 達成基準

     {inferred acceptance criteria, formatted as a markdown checklist}

     ## 注釈

     {inferred notes, or omit this section if nothing relevant}
     ```
   - Show the drafted body to the user and ask: "Does this look good, or would you like to change anything?"
   - Iterate based on feedback until the user is satisfied.
   - Ask for labels (optional, comma-separated).
3. Run `gh issue create` with the collected information. If labels were not provided, omit that flag.
4. Parse the issue number from the URL in the output (e.g., `https://github.com/owner/repo/issues/42` → `42`)
5. Generate a branch slug from the title:
   - Lowercase the title
   - Replace spaces and non-alphanumeric characters with hyphens
   - Collapse consecutive hyphens into one
   - Trim leading/trailing hyphens
   - Keep ~4 meaningful words (drop common stop words like "in", "the", "a", "an", "for", "of", "to" if needed to stay concise)
6. Create a worktree for the new branch:
   ```bash
   REPO_NAME=$(basename "$(git rev-parse --show-toplevel)")
   git worktree add "../${REPO_NAME}-issue-{number}" -b issue-{number}-{slug}
   ```
   Then run project-specific post-setup inside the worktree if applicable:
   ```bash
   # Only if CLAUDE.md documents an APP_PORT convention
   if grep -q "APP_PORT" CLAUDE.md 2>/dev/null; then
     echo "APP_PORT=80{NN}" > "../${REPO_NAME}-issue-{number}/.env"
   fi
   ```
   Port is derived from the convention in CLAUDE.md: `APP_PORT = 8000 + issue number`
   All subsequent steps (Codex, simplify, verify) must run inside the worktree directory.
7. Confirm success by running `git worktree list`
8. Report the issue URL, the new branch name, and the worktree path to the user. If `.env` was created, also report the APP_PORT.
9. Delegate implementation to Codex CLI:
   *(This skill assumes `codex` CLI is already installed and available in `PATH`.)*
   - Fetch the issue title and body separately using `--jq` to avoid jq parse errors from special characters:
     ```bash
     ISSUE_TITLE=$(gh issue view {number} --json title --jq '.title')
     ISSUE_BODY=$(gh issue view {number} --json body --jq '.body')
     ```
   - Extract the 達成基準 section into `$CRITERIA` — take everything between the `## 達成基準` heading and the next `##` heading (or end of string):
     ```bash
     CRITERIA=$(echo "$ISSUE_BODY" | awk '/^## 達成基準/{found=1; next} found && /^## /{exit} found{print}')
     OUT_OF_SCOPE=$(echo "$ISSUE_BODY" | awk '/^## 注釈/{found=1; next} found && /^## /{exit} found{print}')
     ```
   - Look for a project conventions file by checking `AGENTS.md`, `CODEX.md`, and `CLAUDE.md` in that order. Read the first one found into `$CONVENTIONS`; if none exist, leave it empty:
     ```bash
     CONVENTIONS=""
     for f in AGENTS.md CODEX.md CLAUDE.md; do
       if [ -f "$f" ]; then CONVENTIONS=$(cat "$f"); break; fi
     done
     ```
   - Build the prompt. If `$CONVENTIONS` is non-empty, include a `## Project Conventions` section and a "Follow the project conventions above" instruction; otherwise omit both:
     ```bash
     PROMPT=$(printf 'Implement this GitHub issue. Do not run git commands or create commits.\n\nIssue: %s\n\n## 達成基準\n\n%s\n' "$ISSUE_TITLE" "$CRITERIA")
     if [ -n "$CONVENTIONS" ]; then
       PROMPT=$(printf '%s\n\n## Project Conventions\n\n%s\n\n## Instructions\n- Implement every checklist item in 達成基準\n- Follow the project conventions above\n- Explore the codebase to understand context\n- Only modify files needed to satisfy the criteria\n- Do NOT implement anything beyond the 達成基準 checklist items above\n- Do NOT add endpoints, business logic, or features not explicitly listed\n- Do not commit\n' "$PROMPT" "$CONVENTIONS")
     else
       PROMPT=$(printf '%s\n\n## Instructions\n- Implement every checklist item in 達成基準\n- Explore the codebase to understand context\n- Only modify files needed to satisfy the criteria\n- Do NOT implement anything beyond the 達成基準 checklist items above\n- Do NOT add endpoints, business logic, or features not explicitly listed\n- Do not commit\n' "$PROMPT")
     fi
     if [ -n "$OUT_OF_SCOPE" ]; then
       PROMPT=$(printf '%s\n\n## スコープ外（実装しないこと）\n\n%s\n' "$PROMPT" "$OUT_OF_SCOPE")
     fi
     ```
   - Write the prompt to a temp file and invoke `codex exec --sandbox workspace-write`. If codex fails for any reason, stop and report the error:
     ```bash
     PROMPT_FILE="/tmp/codex_prompt_issue_{number}.txt"
     printf '%s' "$PROMPT" > "$PROMPT_FILE"
     OUTPUT=$(codex exec --sandbox workspace-write - < "$PROMPT_FILE" 2>&1)
     EXIT=$?
     if [ $EXIT -ne 0 ]; then
       echo "$OUTPUT"; exit $EXIT
     fi
     ```
   - After success, inform the user: "Codex finished implementing. Proceeding to simplify and verify."
10. Invoke /simplify to review the changed code. For each fix identified by /simplify, delegate the fix to Codex via a focused `codex exec` prompt — do NOT apply fixes directly yourself.
11. Verify 達成基準 before committing:
    - Re-read each checklist item in 達成基準 from the issue body
    - For each item, confirm it is satisfied by reviewing the implemented code
    - If any item is not yet satisfied, re-run Codex with a focused prompt describing only the missing item. Do NOT implement it yourself.
    - For each verified item, update the GitHub issue body to check off that checkbox using `gh issue edit {number} --body "..."`
    - Show a summary of verified items to the user before proceeding
12. Show a summary of all changes for the user to review before committing:
    - Run `git diff --stat HEAD` to show which files were changed
    - Run `git diff HEAD` to show the full diff
    - Inform the user: "Implementation complete. Please review the changes above and run /commit when ready."
    - Do NOT invoke /commit automatically

## Arguments

`$ARGUMENTS` — Optional. Used as the issue title, or as context to understand what issue to create.

## Error Handling

- If `gh` is not authenticated, show the error clearly and suggest running `gh auth login`
- If no git remote exists, inform the user that a remote is required for `gh issue create`
- If branch creation fails (e.g., branch already exists), report the error and suggest a corrected branch name
- If Codex fails for any reason (sandbox permission, flag error, etc.):
  1. Diagnose the root cause from the error output
  2. Fix the root cause (e.g., correct the flag, fix the prompt file)
  3. Re-run Codex with the corrected command
  4. Do NOT implement the code yourself — implementation is Codex's responsibility

## Examples

```
/issue add dark mode support
```
Creates issue "add dark mode support", then checks out `issue-7-add-dark-mode`.

```
/issue
```
Prompts for title, drafts the body, then asks the user to confirm or refine before creating the issue.

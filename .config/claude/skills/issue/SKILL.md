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
6. Run `git checkout -b issue-{number}-{slug}`
7. Confirm success by running `git branch --show-current`
8. Report the issue URL and the new branch name to the user
9. Delegate implementation to Codex CLI:
   *(This skill assumes `codex` CLI is already installed and available in `PATH`.)*
   - Fetch the issue as JSON and extract variables:
     ```bash
     ISSUE_JSON=$(gh issue view {number} --json title,body)
     ISSUE_TITLE=$(echo "$ISSUE_JSON" | jq -r '.title')
     ISSUE_BODY=$(echo "$ISSUE_JSON" | jq -r '.body')
     ```
   - Extract the 達成基準 section into `$CRITERIA` — take everything between the `## 達成基準` heading and the next `##` heading (or end of string):
     ```bash
     CRITERIA=$(echo "$ISSUE_BODY" | awk '/^## 達成基準/{found=1; next} found && /^## /{exit} found{print}')
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
       PROMPT=$(printf '%s\n\n## Project Conventions\n\n%s\n\n## Instructions\n- Implement every checklist item in 達成基準\n- Follow the project conventions above\n- Explore the codebase to understand context\n- Only modify files needed to satisfy the criteria\n- Do not commit\n' "$PROMPT" "$CONVENTIONS")
     else
       PROMPT=$(printf '%s\n\n## Instructions\n- Implement every checklist item in 達成基準\n- Explore the codebase to understand context\n- Only modify files needed to satisfy the criteria\n- Do not commit\n' "$PROMPT")
     fi
     ```
   - Invoke codex, preferring `--approval-mode auto-edit` (files auto-approved, shell commands still prompt). If that flag is unsupported by the installed version — indicated by an "unknown flag", "unknown option", or similar usage error on stderr — retry using the non-interactive flag appropriate for that version (e.g. `-q`). For any other non-zero exit, stop and report the error without retrying:
     ```bash
     OUTPUT=$(printf '%s' "$PROMPT" | codex --approval-mode auto-edit - 2>&1)
     EXIT=$?
     if [ $EXIT -ne 0 ] && echo "$OUTPUT" | grep -qiE 'unknown (flag|option)|unrecognized option'; then
       printf '%s' "$PROMPT" | codex -q -  # -q is one example; check `codex --help` for your version
     elif [ $EXIT -ne 0 ]; then
       echo "$OUTPUT"; exit $EXIT
     fi
     ```
   - After success, inform the user: "Codex finished implementing. Proceeding to simplify and verify."
10. Invoke /simplify to review the changed code and apply any fixes found
11. Verify 達成基準 before committing:
    - Re-read each checklist item in 達成基準 from the issue body
    - For each item, confirm it is satisfied by reviewing the implemented code
    - If any item is not yet satisfied, continue implementation until it is
    - For each verified item, update the GitHub issue body to check off that checkbox using `gh issue edit {number} --body "..."`
    - Show a summary of verified items to the user before proceeding
12. Invoke /commit to create a commit for the completed work

## Arguments

`$ARGUMENTS` — Optional. Used as the issue title, or as context to understand what issue to create.

## Error Handling

- If `gh` is not authenticated, show the error clearly and suggest running `gh auth login`
- If no git remote exists, inform the user that a remote is required for `gh issue create`
- If branch creation fails (e.g., branch already exists), report the error and suggest a corrected branch name

## Examples

```
/issue add dark mode support
```
Creates issue "add dark mode support", then checks out `issue-7-add-dark-mode`.

```
/issue
```
Prompts for title, drafts the body, then asks the user to confirm or refine before creating the issue.

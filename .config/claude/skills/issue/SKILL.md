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
9. Proceed to implement the issue:
   - Use the issue title and the 達成基準 checklist as the implementation guide
   - Explore the codebase as needed to understand the context
   - Implement each checklist item in turn, marking them off as you go
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

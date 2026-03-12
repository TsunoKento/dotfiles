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
2. If `$ARGUMENTS` is provided, use it as the issue title. Otherwise, ask the user for:
   - **Title** (required)
   - **Body** (optional)
   - **Labels** (optional, comma-separated)
3. Run `gh issue create` with the collected information. If body or labels were not provided, omit those flags.
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
Prompts for title, optional body, and optional labels before proceeding.

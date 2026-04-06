---
name: issue
description: >
  Create a GitHub Issue and a corresponding worktree branch for issue-driven development.
  Use this skill whenever the user wants to start working on a new feature, bug fix,
  or task — even if they say "create an issue for X", "start working on X",
  "make a ticket for X", or "let's tackle X". This skill handles issue creation and
  worktree setup. Use /implement afterwards to delegate implementation to Codex.
---

# Issue-Driven Development Skill

Create a GitHub Issue and set up an isolated worktree branch in one step.

## Branch Naming Convention

```
issue-{number}-{short-slug}
```

Slug is derived from the issue title: lowercase, spaces/special characters replaced
with hyphens, ~4 meaningful words (drop stop words like "in", "the", "a", "an",
"for", "of", "to").

| Issue title | Branch |
|---|---|
| "Add web server setup" | `issue-1-web-server-setup` |
| "Fix auth bug in login" | `issue-42-fix-auth-bug` |
| "Add dark mode support" | `issue-7-add-dark-mode` |

---

## Instructions

### 1. Check the base branch

Confirm the current branch looks like an appropriate base (e.g., `main`, `master`,
`develop`). If already on a feature branch, ask the user whether to continue from there.

### 2. Collect issue details

- If `$ARGUMENTS` is provided, use it as the issue title. Otherwise ask for the title.
- Draft the issue body from the title using this template:

  ```
  ## 背景

  {inferred background / problem statement}

  ## 達成基準

  {inferred acceptance criteria, formatted as a markdown checklist}

  ## 注釈

  {inferred notes, or omit this section if nothing relevant}
  ```

- Show the draft and ask: "Does this look good, or would you like to change anything?"
  Iterate until the user is satisfied.
- Ask for labels (optional, comma-separated).

### 3. Create the GitHub issue

```bash
gh issue create --title "..." --body "..." [--label "..."]
```

Parse the issue number from the URL in the output (e.g., `.../issues/42` → `42`).

> If `gh` is not authenticated, surface the error and suggest `gh auth login`.
> If no git remote exists, explain that a remote is required.

### 4. Create a worktree for the new branch

Working in an isolated worktree keeps the main branch clean and lets you run the
dev server on a separate port without conflicts.

```bash
REPO_NAME=$(basename "$(git rev-parse --show-toplevel)")
git worktree add "../${REPO_NAME}-issue-{number}" -b issue-{number}-{slug}
```

If CLAUDE.md documents an `APP_PORT` convention, create a `.env` file so the
dev server uses a non-conflicting port (`APP_PORT = 8000 + issue number`):

```bash
if grep -q "APP_PORT" CLAUDE.md 2>/dev/null; then
  echo "APP_PORT=80{NN}" > "../${REPO_NAME}-issue-{number}/.env"
fi
```

Confirm success with `git worktree list`.

> If branch creation fails (e.g., already exists), report the error and suggest
> a corrected branch name.

### 5. Report to the user

Show the issue URL, new branch name, worktree path, and APP_PORT (if created).

Then suggest: "Ready to implement? Run `/implement {number}` in the worktree directory."

---

## Arguments

`$ARGUMENTS` — Optional. Used as the issue title, or as context to understand
what issue to create.

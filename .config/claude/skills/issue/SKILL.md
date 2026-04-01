---
name: issue
description: >
  Create a GitHub Issue and a corresponding branch for issue-driven development.
  Use this skill whenever the user wants to start working on a new feature, bug fix,
  or task — even if they say "create an issue for X", "start working on X",
  "make a ticket for X", or "let's tackle X". This skill handles the full cycle:
  issue creation, worktree setup, Codex implementation, simplify review, and
  acceptance criteria verification.
---

# Issue-Driven Development Skill

Create a GitHub Issue and set up an isolated worktree branch in one step, then
delegate implementation to Codex.

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

### 6. Delegate implementation to Codex

All subsequent steps run **inside the worktree directory**.

Codex handles implementation so that Claude stays focused on orchestration and
review rather than writing code directly.

```bash
cd "../${REPO_NAME}-issue-{number}"
bash <skill-dir>/scripts/build_codex_prompt.sh {number}
```

`scripts/build_codex_prompt.sh` fetches the issue, extracts `達成基準` and `注釈`,
finds the project conventions file (`AGENTS.md` / `CODEX.md` / `CLAUDE.md`),
builds a focused prompt, and runs `codex exec --sandbox workspace-write`.

> If Codex fails: diagnose the root cause from the error output, fix it (e.g.,
> correct a flag or the prompt), and re-run. Do NOT implement code yourself —
> implementation is Codex's responsibility.

After success, inform the user: "Codex finished. Proceeding to simplify and verify."

### 7. Run /simplify

Invoke `/simplify` to review the changed code for quality and reuse issues.
For each fix identified, delegate it to Codex via a focused `codex exec` prompt —
do NOT apply fixes yourself.

### 8. Verify 達成基準

Re-read each checklist item from the issue body and confirm it is satisfied by
the implemented code. If any item is missing, re-run Codex with a focused prompt
for that item only.

For each verified item, check it off in the issue:

```bash
gh issue edit {number} --body "..."
```

Show a summary of verified items before proceeding.

### 9. Show the diff for review

```bash
git diff --stat HEAD
git diff HEAD
```

Tell the user: "Implementation complete. Please review the changes above and
run /commit when ready."

Do NOT invoke /commit automatically.

---

## Arguments

`$ARGUMENTS` — Optional. Used as the issue title, or as context to understand
what issue to create.

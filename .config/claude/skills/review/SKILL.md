---
name: review
description: >
  Review implemented code for a GitHub Issue: run /code-review and fix findings,
  run /simplify, verify acceptance criteria, and show the diff. Run this after /implement has finished.
  Use when the user says "review issue N", "review the changes", "/review N", or similar.
  Must be run from inside the worktree directory for the issue.
---

# Review Skill

Review implemented code, verify acceptance criteria, and prepare for commit.

---

## Instructions

### 1. Get the issue number

- If `$ARGUMENTS` is provided, use it as the issue number.
- Otherwise, ask: "Which issue number should I review?"

### 2. Run /code-review

Invoke `/code-review medium --fix` to review the current diff for correctness bugs and
apply fixes for the findings. Report what was found and fixed before
proceeding.

### 3. Run /simplify

After the /code-review fixes are applied, invoke `/simplify` to review the
changed code for quality and reuse issues, and apply any fixes found.

### 4. Verify 達成基準

Re-read each checklist item from the issue body and confirm it is satisfied by
the implemented code. If any item is missing, note it for the user.

For each verified item, check it off in the issue:

```bash
gh issue edit {number} --body "..."
```

Show a summary of verified items before proceeding.

### 5. Show the diff for review

```bash
git diff --stat HEAD
git diff HEAD
```

Tell the user: "Review complete. Please review the changes above and
run /commit when ready."

Do NOT invoke /commit automatically.

---

## Arguments

`$ARGUMENTS` — Optional. The issue number to review.

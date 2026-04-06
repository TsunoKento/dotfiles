---
name: review
description: >
  Review implemented code for a GitHub Issue: run /simplify, get a Codex code review,
  verify acceptance criteria, and show the diff. Run this after /implement has finished.
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

### 2. Run /simplify

Invoke `/simplify` to review the changed code for quality and reuse issues, and
apply any fixes found.

### 3. Codex code review

Run Codex to get an independent code review of the changes. Codex should report
issues only — it does NOT make fixes.

```bash
codex exec --sandbox read-only "You are a code reviewer. Run \`git diff HEAD\` to see the changes made for issue #{number}. Review the diff for bugs, edge cases, security issues, or style problems. List your findings clearly. Do NOT modify any files."
```

Show the Codex review output to the user. If no issues are found, note that and
continue.

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

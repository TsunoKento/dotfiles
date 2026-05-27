---
name: implement
description: >
  Implement a GitHub Issue using strict TDD (Red → Green per behavior).
  Run this after /issue has created the issue and worktree. Use when the user says
  "implement issue N", "start implementation", "/implement N", or similar.
  Must be run from inside the worktree directory for the issue.
  Use /review afterwards to review and verify.
---

# Implementation Skill (TDD)

Implement a GitHub Issue one behavior at a time using strict TDD.

---

## TDD Principles

- Only one behavior per cycle
- Write a failing test first — do NOT write any implementation yet
- After adding a test, run it and confirm it fails (Red)
- Write only the minimum implementation to make the test pass (Green)
- Do NOT anticipate or implement the next requirement
- Keep each change as small as possible

---

## Instructions

### 1. Get the issue number

- If `$ARGUMENTS` is provided, use it as the issue number.
- Otherwise, ask: "Which issue number should I implement?"

### 2. Confirm the worktree

Check that the current directory is the worktree for the issue:

```bash
git branch --show-current
```

The branch should match `issue-{number}-*`. If not, ask the user to `cd` into
the correct worktree directory first.

### 3. Break down the issue into behaviors

Fetch the issue:

```bash
gh issue view {number}
```

Read the `## 達成基準` checklist. Break each item into individual **behaviors** —
the smallest testable unit of functionality. Present the list to the user:

```
この issue を以下の振る舞いに分解しました:

1. {behavior 1}
2. {behavior 2}
3. {behavior 3}
...

最初の振る舞いからテストを書きます。
```

Follow any project conventions defined in `AGENTS.md`, `CODEX.md`, or `CLAUDE.md`
if present.

### 4. TDD cycle (repeat for each behavior)

#### Red — Write a failing test

Write **only** a test for the current behavior. Do NOT write any implementation.

Run the test and confirm it fails:

```bash
{project's test command}
```

Show the failure output.

#### Green — Write minimal implementation

Write the **minimum** code to make the failing test pass. Do NOT implement
anything beyond what the test requires.

Run the test again and confirm it passes:

```bash
{project's test command}
```

Show the result.

#### Pause — Wait for user review

After Green passes, **stop and wait for explicit user approval** before
starting the next behavior. Do NOT proceed automatically.

Show a brief summary so the user can review the cycle:

```
✅ サイクル {N} 完了: {behavior}

変更ファイル:
- {test file path}
- {implementation file path}

テスト結果: {pass count} passed

次の振る舞い: {next behavior}

このまま次のサイクルに進んでよいか確認してください。修正・質問があればどうぞ。
```

Then wait. Only continue to the next **Red** when the user explicitly
approves (e.g. "OK", "進めて", "次へ"). If the user asks questions or
requests changes, address them first and re-show the pause prompt before
continuing.

### 5. Completion

After all behaviors are implemented and all tests pass:

```
全ての振る舞いを TDD で実装しました。
`/review {number}` でレビューと検証を行ってください。
```

Do NOT commit.

---

## Arguments

`$ARGUMENTS` — Optional. The issue number to implement.

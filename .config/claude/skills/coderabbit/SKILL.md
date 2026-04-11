---
name: coderabbit
description: >
  Fetch, summarize, and classify CodeRabbit PR review comments, then apply
  necessary fixes. Takes a PR number as an argument or auto-detects the PR
  for the current branch.
  Use when the user says "coderabbit", "handle coderabbit comments",
  "review coderabbit", "/coderabbit", "/coderabbit 42", or similar.
allowed-tools: Bash(gh:*) Bash(git:*) Bash(jq:*)
---

# CodeRabbit Review Skill

Fetch, summarize, and classify CodeRabbit PR review comments, then apply necessary fixes.

---

## Instructions

### 1. Determine PR Number

- If `$ARGUMENTS` is a number, use it as the PR number
- Otherwise, auto-detect via `gh pr view --json number --jq '.number'`
- If no PR is found, report the error and exit

Get the repository owner/repo via `gh repo view --json owner,name --jq '"\(.owner.login)/\(.name)"'`.

### 2. Fetch CodeRabbit Comments

Collect comments from the following 3 API endpoints:

```bash
# Inline comments (on code lines)
gh api --paginate repos/{owner}/{repo}/pulls/{number}/comments

# Review summaries
gh api --paginate repos/{owner}/{repo}/pulls/{number}/reviews

# Comments on the PR body
gh api --paginate repos/{owner}/{repo}/issues/{number}/comments
```

Filter each response to extract only CodeRabbit comments. Use
`select(.user.login | test("coderabbit"))` for partial matching to cover
both `coderabbitai` and `coderabbitai[bot]`.

If zero comments are found, report that no CodeRabbit comments were found and exit.

### 3. Summarize and Classify Comments

#### Review Summary

Display the CodeRabbit review summary (body from the reviews endpoint) as a
2-3 line overview at the top.

#### Inline Comment Classification Table

Summarize each inline comment in one line (in Japanese) and classify it into
one of 3 severity levels:

```
| # | File | Line | Summary | Severity |
|---|------|------|---------|----------|
| 1 | path/to/file.go | 42 | 未使用の変数errを処理すべき | 要対応 |
| 2 | path/to/other.go | 15 | nilチェックの追加を推奨 | 検討 |
| 3 | internal/api.go | 88 | コメントの誤字指摘 | 対応不要 |
```

Classification criteria:

- **要対応** (Must fix): Bugs, security issues, unhandled errors, clear logic mistakes
- **検討** (Consider): Performance/design improvements, best practice suggestions (valid but not mandatory)
- **対応不要** (Skip): Style preferences, already addressed, false positives, suggestions that conflict with project conventions

### 4. Ask User for Selection

After displaying the table, ask the user which items to fix:

- `yes` or Enter → All **要対応** items
- `all` → All **要対応** + **検討** items
- `1,3,5` → Specific items by number
- `no` → Exit without fixing

### 5. Apply Fixes

For each selected item:

1. Read the target file and line, referencing the full original CodeRabbit comment
2. If the comment includes a code block, use it as a reference for the fix
3. If the suggestion is ambiguous, determine the best fix from code context
4. After fixing, briefly report what was changed

Commit each fix individually using `/commit`. Do NOT batch all fixes into a
single commit. Include the comment number and summary in each commit message.

After all fixes are complete, report in this format:

```
## Done

Applied fixes for {N} comments.

Each fix has been committed individually:
- abc1234 fix: handle unused error variable (#1)
- def5678 fix: add nil check (#2)
```

### 6. (Optional) React to Comments

Add a `+1` reaction to each fixed inline comment:

```bash
gh api repos/{owner}/{repo}/pulls/comments/{comment_id}/reactions -f content='+1'
```

For issue comments:

```bash
gh api repos/{owner}/{repo}/issues/comments/{comment_id}/reactions -f content='+1'
```

---

## Arguments

`$ARGUMENTS` — Optional. PR number. If omitted, auto-detects the PR for the current branch.

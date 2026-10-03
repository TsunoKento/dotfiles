---
name: post-merge
description: >
  Clean up local branches after a PR has been merged.
  Leave the issue worktree, switch to main, pull latest, and delete the merged
  feature branch and its worktree.
allowed-tools: Bash(git:*)
---

# Post-Merge Branch Cleanup

Clean up the local environment after a PR has been merged.

## Instructions

1. Record the current branch name (this is the branch to delete) and the
   current directory (`git rev-parse --show-toplevel`).
2. Check whether the current directory is a linked worktree (it appears in
   `git worktree list` and is not the first entry, which is the main worktree).
   - **If it is a worktree:**
     1. If Docker containers are running for it, stop them with
        `docker compose down` in the worktree.
     2. Call the `ExitWorktree` tool with `action: "keep"` to return the
        session to the main worktree. (A worktree created with `git worktree add`
        is never removed by `ExitWorktree`.)
     3. Run `git worktree remove <worktree-path>`. If it fails because of
        untracked or modified files, show them and confirm with the user before
        using `--force`.
   - **If it is not a worktree:** run `git switch main`.
3. Run `git pull --prune` on `main` to fetch the latest and prune
   remote-tracking branches that no longer exist on the remote.
4. Run `git branch -d <feature-branch>` to delete the merged branch.
5. Confirm with `git worktree list` and `git branch`.

## Edge Cases

- If already on `main` in the main worktree, ask the user which branch (and
  worktree) to delete.
- If `ExitWorktree` reports no active worktree session (e.g., Claude was started
  directly in the worktree), tell the user to restart Claude in the main
  repository and run `/post-merge` there, naming the branch to delete.
- If `git branch -d` fails (branch not fully merged), confirm with the user
  before using `-D`.
- If there are uncommitted changes, abort and report to the user.

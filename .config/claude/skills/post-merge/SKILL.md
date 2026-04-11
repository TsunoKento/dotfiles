---
name: post-merge
description: >
  Clean up local branches after a PR has been merged.
  Switch to main, pull latest, and delete the merged feature branch.
allowed-tools: Bash(git:*)
---

# Post-Merge Branch Cleanup

Clean up the local environment after a PR has been merged.

## Instructions

1. Record the current branch name (this is the branch to delete).
2. Run `git switch main` to move to the main branch.
3. Run `git pull --prune` to fetch the latest and prune remote-tracking branches
   that no longer exist on the remote.
4. Run `git branch -d <feature-branch>` to delete the merged branch.

## Edge Cases

- If already on `main`, ask the user which branch to delete.
- If `git branch -d` fails (branch not fully merged), confirm with the user
  before using `-D`.
- If there are uncommitted changes, abort and report to the user.

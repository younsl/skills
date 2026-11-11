---
name: principle-not-your-diff
description: "Apply when the working tree, git index, Terraform state, or cloud resources are shared with other sessions or teammates. Never let your commit, stash, or apply carry someone else's work."
disable-model-invocation: true
---

# Not your diff

Never let your commit, stash, or apply carry someone else's work.

**Why:** Shared checkouts move under you. A plain `git commit`, `git add -A`, `git stash`, or a branch assumed from the last turn has pushed other people's WIP to public main and polluted their branches.

## Output Requirements

- Stage and commit explicit paths only (pathspec commit). Never `git add -A`, never unstage what another session staged.
- Before every follow-up commit, the current branch is compared with the expected one. A mismatch stops the commit.
- Side branches are worked in a separate worktree, never by switching the shared checkout. No bare `git stash`.
- After commit and push, the commit's file list and the commits stacked around it are checked.
- A teammate's unmerged change showing up as drift in your plan is not applied, reverted, or imported. Target your own resources or stop and report.

## Validation

- The pushed commit's file list (`git show --stat HEAD`) contains only your paths.
- The current branch matched the expected branch before every commit.

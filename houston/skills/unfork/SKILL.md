---
name: unfork
description: Delete the authenticated GitHub user's forked repositories that have no open pull request, on GitHub and in their local clones, while keeping every fork an open pull request still depends on and every clone holding work that exists nowhere else.
when_to_use: Cleaning up personal GitHub forks, e.g. "PR 없는 포크 삭제", "포크 레포 정리", "안 쓰는 fork 지워줘", "머지된 PR 포크 정리", "clean up my forks", "delete stale forks". Not for deleting a non-fork repository, organization-owned forks, or branches inside a repository (use git-ship), and not for freeing disk space (use disk-cleanup).
argument-hint: "[--keep name ...]"
license: Apache-2.0
compatibility: gh authenticated with the delete_repo scope, git, bash 3.2+
metadata:
  version: "1.0.0"
  category: action
  related: disk-cleanup git-ship
allowed-tools: Bash(*/unfork/scripts/unfork.sh --dry-run*) Bash(gh auth status*) Read Grep
user-invocable: true
disable-model-invocation: false
---

# Unfork

## Output Requirements

- `scripts/unfork.sh` (in this skill's base directory) does the discovery and the deletion. No hand-written `gh repo delete` or `rm -rf` per repository, because the script is what checks every keep condition
- Every run starts with `--dry-run`, and the `would-delete` and `kept` rows are shown to the user. The deleting run happens only after the user confirms that list in the same conversation, since a deleted fork cannot be restored from the CLI and its unmerged branches go with it
- The deleting run repeats the dry run's `--root` and `--keep` arguments, so it acts on the list the user saw
- A fork the user wants to spare is passed with `--keep`, never worked around by editing the list
- Scope is forks owned by the account `gh` is logged in as. Organization-owned forks and non-fork repositories are never candidates, whatever the request says
- A missing `delete_repo` scope is fixed by the user, who runs `gh auth refresh -h github.com -s delete_repo` through the `!` prompt prefix. The flow is interactive and widens the token, so it is not run on their behalf
- The request to "delete forks without open PRs" covers merged and closed pull requests too: once nothing is open, the fork is a candidate

## Keep Conditions

A fork matching any row is kept on GitHub and locally.

| Condition | Why |
|-----------|-----|
| An open pull request by the user has its head branch in the fork | Deleting the fork closes the pull request and loses its branch |
| An open pull request targets the fork itself | Someone is waiting on a review there |
| A local clone has uncommitted or untracked changes, or stash entries | Work that exists only on this machine |
| A local clone has commits not pushed to any remote | Same, and the fork is where they would be pushed |
| A local clone has linked worktrees, or contains the current directory | Removing it breaks a live checkout or the running shell |
| Named with `--keep` | The user said so |

Branches pushed to the fork without a pull request do not keep it. Call these out before confirmation when the user mentions work in progress on a fork.

## Reference

| Item | Behavior |
|------|----------|
| Local clone discovery | Any git directory up to 4 levels under `--root` (default `~/github`) with a remote of any name pointing at the fork |
| Clone of upstream with the fork as a second remote | Counted as the fork's clone and removed with it |
| Order | Remote first, then local. A failed remote delete leaves the clone in place |
| `failed remote ... 403` | Token lacks `delete_repo`, or the repository needs admin rights the account does not have |
| Fork missing from the list | Owned by an organization, or its upstream was deleted and GitHub no longer marks it as a fork |
| Pull request opened from the fork by another account | Not detected. Ask when the fork has collaborators |

## Report

- Account the run acted as
- Table of deleted forks with their upstream and the local path removed, if any
- Kept forks with the reason, pull request links included
- `failed` rows with the error line, and the fact that nothing else was retried

## Validation

- A second `--dry-run` shows zero `would-delete` rows
- `gh repo list --fork` no longer lists the deleted forks, and still lists every kept one
- Each removed local path no longer exists, and every kept clone is unchanged

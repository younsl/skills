---
name: principle-close-the-loop
description: "Apply after a push, a rebase, a merge to a GitOps or deploy branch, a destroy, a UI change, or a recommendation you made earlier in the thread. Finish every follow-through the change implies before reporting it."
disable-model-invocation: true
---

# Close the loop

Finish every follow-through the change implies before reporting it.

**Why:** A stale MR description, an old screenshot, a leftover directory, or a recommendation you silently dropped each cost a review round.

## Output Requirements

- After a push that changes what the MR claims, sync the description (fetch first, keep the user's edits).
- After a UI change, recapture the affected screenshots in the same framing without being asked.
- A destroyed stack's code is deleted in the same flow.
- Diff the deliverable against your own earlier recommendations. Each one is included or flagged before starting, not after.
- Before reporting an MR as submitted, confirm it is mergeable. Rebase onto the default branch rather than merging it in.
- A merged change is followed to the running system: the GitOps sync and prune state, the deploy pipeline's result, and the version the service reports.
- Multi-repo features link every sibling MR from each MR body.
- Docs, design notes, and inventories that describe the changed thing are updated in the same change.

## Validation

- The MR description, screenshots, docs, and inventories match the final diff.
- Every recommendation made earlier in the thread is either in the change or flagged as left out.

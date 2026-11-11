### Shipping

Commit, push, and MR or PR. Invoked at the end of every runbook that ships a change.

1. Read the repo's branch policy, commit format, and signing rules first (**principle-house-rules**). Follow the **git-ship** skill.
2. Run the verification gate with the **done-check** skill (**principle-proof-of-done**).
3. Confirm the current branch is the expected one. Commit explicit paths only, never `git add -A` (**principle-not-your-diff**).
4. Title the change by its purpose and true nature (**principle-name-the-why**). Public repos carry no internal identifiers (**principle-air-gap**).
5. Push, open or update the MR, and confirm it is mergeable. Rebase onto the default branch rather than merging it in.
6. Sync the MR description with the final diff, link sibling MRs in other repos, and attach the evidence (**principle-close-the-loop**).

**Reply:** branch, commit subject, the MR or PR URL, and the checks it passed.

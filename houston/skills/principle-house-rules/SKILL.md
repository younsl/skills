---
name: principle-house-rules
description: "Apply when committing, pushing, opening an MR, or releasing in any repo. Let each repo's own policy decide branching, review, signing, and release ceremony."
disable-model-invocation: true
---

# House rules

Let each repo's own policy decide branching, review, signing, and release ceremony.

**Why:** The same "commit and push" means a direct push in one repo and a branch plus MR in another. Getting it wrong either bypasses review or adds a round trip nobody wanted.

## Output Requirements

- Branch policy (direct push versus MR), commit format, and sign-off rules come from the repo's own docs and memory, read first.
- Where direct push is the norm, no feature branch or MR is offered unless asked. Where MR is required, nothing goes to the default branch.
- A push rejected by bot commits is rebased and retried, not forced.
- Pushed commits are not amended to fix wording. Titles and descriptions are edited on the MR instead.
- A skill or flow the user explicitly invoked runs end to end without confirmation pauses, except where a version mismatch or barred path ends it.

## Validation

- The branch, review, and signing path used matches the repo's documented policy.
- No force-push or amend touched a commit that was already pushed.

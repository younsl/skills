---
name: principle-name-the-why
description: "Apply when writing a commit subject, MR title, or ticket title. Describe a change by its purpose and its true nature, not by its mechanism."
disable-model-invocation: true
---

# Name the why

Describe a change by its purpose and its true nature, not by its mechanism.

**Why:** "Bump X to 1.2.3" hides that it fixes an incident. "Add Y" hides that Y was missing and should have been there. Reviewers misjudge risk from the wrong verb.

## Output Requirements

- A version bump that serves a fix is titled as the fix, with the version after it.
- Wording distinguishes new, restored-after-being-lost (backport), and previously-missing.
- Refactors are labeled as refactors in type, title, and body.
- Codifying existing live state is described as reproducibility, not a rollout.
- Ticket titles append the purpose in a few words. MR titles stay free of parenthetical asides.

## Reference

- **Bad:** `bump(foo): 0.6.0 to 0.6.1`.
- **Good:** `fix(foo): make the preflight check compatible with the new alert path (0.6.1)`.

## Validation

- The title says what the change achieves, and a bump that serves a fix is titled as the fix.
- The verb distinguishes new, restored, and previously missing.

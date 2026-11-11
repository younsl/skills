---
name: principle-reviewable-units
description: "Apply when the same change spans several branches or environments, or a follow-up touches many files. Ship one logical change as one reviewable unit, and finish each unit before starting the next."
disable-model-invocation: true
---

# Reviewable units

Ship one logical change as one reviewable unit, and finish each unit before starting the next.

**Why:** Per-branch units let the reviewer approve each environment separately. Fanning one change into many MRs or parallel agents multiplies review cost.

## Output Requirements

- Multi-branch changes go branch by branch: read, edit, commit, push, then move on.
- A follow-up across many files is one branch and one MR. Splitting is asked about first.
- The exception is a deliberate phase split, such as a parallel-run MR followed by a cutover MR.
- Related commits that ship outside the MR (for example in another repo) are named in that MR.

## Validation

- Each MR or commit contains one logical change for one branch or environment.
- Work on the next unit started only after the previous unit was pushed.

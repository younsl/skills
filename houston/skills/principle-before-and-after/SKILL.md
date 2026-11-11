---
name: principle-before-and-after
description: "Apply when claiming a performance gain, a refactor with no behavior change, a no-op codification, or a component replacement. Prove a change's effect by running the same scenario on the old and new version side by side."
disable-model-invocation: true
---

# Before and after

Prove a change's effect by running the same scenario on the old and new version side by side.

**Why:** Unit tests prove code runs, not that it got faster or stayed equivalent. Reviewers trust a no-op only when they see it.

## Output Requirements

- Performance changes ship only after at least two cycles of the same benchmark against the previous release build, plus a happy-path regression run. No improvement or any regression means no commit.
- Refactors are compared against the default branch scenario by scenario, with a main, branch, verdict table.
- Codifying config that already exists live is shown as a no-op with the current live state attached, and described as reproducibility, not a new rollout.
- Results are recorded with the change (MR test section or changelog) as numbers.

## Validation

- The change record contains the old and new results for the same scenario as numbers.
- A claimed no-op shows the live state it matches.

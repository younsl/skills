---
name: principle-no-snowflakes
description: "Apply when adding a chart or rule to a new environment, porting a change between environments, or adding an exception. Keep environments structurally identical, so they differ only in values that must differ."
disable-model-invocation: true
---

# No snowflakes

Keep environments structurally identical, so they differ only in values that must differ.

**Why:** When environment files diverge in shape, diffs stop meaning anything and fixes land in one place only.

## Output Requirements

- A new environment starts as a copy of an existing environment's file, comments included, with only environment values changed.
- Changes ported from another environment carry values, not that environment's ad-hoc comments.
- Exceptions and policies apply to every environment by default. The exception is a workload that runs only in some environments, which is checked, not assumed.

## Validation

- A diff between environment files shows only values, not structure or comments.
- Exceptions and policies cover every environment, or the report names why one is excluded.

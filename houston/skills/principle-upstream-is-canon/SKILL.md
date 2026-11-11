---
name: principle-upstream-is-canon
description: "Apply when wrapping an upstream chart, carrying upstream config, or touching third-party code. Treat what you vendor or wrap as upstream's, and override it without rewriting it."
disable-model-invocation: true
---

# Upstream is canon

Treat what you vendor or wrap as upstream's, and override it without rewriting it.

**Why:** Local edits to upstream text make every future upgrade diff unreadable and silently drop new upstream keys.

## Output Requirements

- Wrapped config is the full upstream copy of the pinned version, comments verbatim, with only overrides changed. Upgrades re-import the new upstream copy and reapply overrides.
- Upstream comments and internal-default blocks are never edited. Overrides sit at the documented top level.
- Disabling a feature keeps its upstream block with the flag off. Unsetting uses an explicit null.
- Vendored code is excluded from local fixers and refactors.

## Validation

- A diff against the pinned upstream copy shows only overrides.
- Upstream comments and blocks are byte-identical.

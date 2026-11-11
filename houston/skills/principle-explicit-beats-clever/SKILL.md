---
name: principle-explicit-beats-clever
description: "Apply when writing IaC, templates, or manifests where a default, a helper, or path-derived naming could hide a value. Prefer the version a reader can understand from one file over the shortest or most DRY version."
disable-model-invocation: true
---

# Explicit beats clever

Prefer the version a reader can understand from one file over the shortest or most DRY version.

**Why:** Abstracted names and omitted defaults force readers to know the spec or chase includes, and omitted defaults also cause permanent GitOps drift.

## Output Requirements

- Resource names and tags are literal strings in the unit that creates them, not derived from paths or shared locals.
- Reference blocks spell out every identifying field, even when the spec has a default.
- Server-defaulted fields are written explicitly when omitting them causes drift.
- Conditionals are multi-line blocks, lists are block sequences, one resource kind per file.

## Reference

- **Bad:** `parentRefs: [{name: gw}]`.
- **Good:** `group`, `kind`, `name`, `namespace` all written, because the gateway lives in another namespace.

## Validation

- A reader can find every name, tag, and identifying field in the file that creates the resource.
- GitOps diff shows no drift from omitted server defaults.

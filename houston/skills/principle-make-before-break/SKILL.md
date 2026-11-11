---
name: principle-make-before-break
description: "Apply when replacing a collector, image, version, model, policy, or schema that something running depends on. Bring the new path up next to the old one, prove parity, cut over, and only then remove the old."
disable-model-invocation: true
---

# Make before break

Bring the new path up next to the old one, prove parity, cut over, and only then remove the old.

**Why:** Cutting over in one step leaves a gap during rollback. Removing the old version before every consumer moves strands whoever is left.

## Output Requirements

- Replacements run in parallel under a distinguishable label or name, with baseline and diff queries, before the cutover change.
- New versions are added beside old ones (new directory, new tag), not by overwriting, so either can be rebuilt during rollback.
- The old version is removed only after every consumer in every environment is confirmed on the new one.
- Prerequisites go first: account agreements, permissions, and schema changes land before the code or config that needs them, and old permissions are removed only after the switch.
- Mixed fleets keep multi-arch artifacts until every target environment is pinned to one architecture.

## Validation

- The new path ran in parallel with a parity check before the cutover change.
- The old path is removed only in a later change, after every consumer is confirmed on the new one.

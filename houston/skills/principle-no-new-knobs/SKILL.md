---
name: principle-no-new-knobs
description: "Apply when a fix or feature seems to need a new values key, env var, config block, namespace, or instance. Derive, reuse, or default a value before adding a configuration key for it."
disable-model-invocation: true
---

# No new knobs

Derive, reuse, or default a value before adding a configuration key for it.

**Why:** Every knob is a schema change, a doc regeneration, a downstream edit, and one more thing an operator forgets to set. Safety features behind a toggle end up off.

## Output Requirements

- Safety features (leader election, disruption budgets) turn on from existing values such as replica count or the feature's enable flag.
- Endpoints already configured elsewhere are reused, and environment facts are detected at runtime.
- Code-side defaults beat chart knobs. A key is added only when behavior must differ per deployment, and the report states chart impact.
- Extensions join the existing namespace or instance before a new one is proposed.
- Absent keys mean "follow upstream". Do not create them during tuning.

## Validation

- Each new config key has a stated reason why derivation, reuse, or a default could not cover it.
- The report states the chart or config impact of any key that was added.

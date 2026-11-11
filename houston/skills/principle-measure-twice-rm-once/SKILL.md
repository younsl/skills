---
name: principle-measure-twice-rm-once
description: "Apply when deleting, destroying, replacing, tearing down, or committing a data change. Make every irreversible step explicit, rehearsed, and approved before it runs."
disable-model-invocation: true
---

# Measure twice, rm once

Make every irreversible step explicit, rehearsed, and approved before it runs.

**Why:** Plans that looked additive have contained replacements, and auto-teardown has removed nodes the user still wanted to inspect.

## Output Requirements

- Deletes are confirmed first, unless the request itself was the destructive instruction (a "destroy" order, a re-release flow the user invoked). Then the whole flow runs, cleanup included.
- Plans run without taking locks or changing state. Any destroy or replace in a plan stops the apply and is reported.
- Data changes run as rehearse (transaction then rollback), commit, verify, with a backup of touched rows and a check that the session is connected to the intended target.
- Investigation resources (test nodes, debug pods) stay up until the user says to remove them.
- Files copied into a remote container are checked (checksum) before they are executed.

## Validation

- Every delete, destroy, or replace in the run was confirmed or was the explicit request itself.
- Data changes show the rehearsal result, the committed result, and the backup location.

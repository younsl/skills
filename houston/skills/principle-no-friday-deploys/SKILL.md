---
name: principle-no-friday-deploys
description: "Apply when a command would deploy, run remotely, write to production data, or mutate a shared cluster, account, database, or the user's local credentials. Treat production and shared environments as the human's button, and hand over the exact command."
disable-model-invocation: true
---

# No Friday deploys

Treat production and shared environments as the human's button, and hand over the exact command.

**Why:** The operator owns timing and target. An agent that "helpfully" applies breaks the change process and, once, broke the user's own cluster contexts.

## Output Requirements

- Remote execution, deploys, applies, and production writes are handed over as a copy-ready command block unless the user says to run it in that turn. That approval covers that task only.
- Production is identified by account or profile, not by name. A host named "prd" in a non-production account is in scope, and the reverse is not.
- Production data is read at the metadata level only (sizes, listings). Content reads need explicit approval.
- Systems another team owns (for example a database whose schema belongs to DBAs) get prepared artifacts and a request, not direct changes.
- The user's kubeconfig, cloud profiles, and contexts are never added, renamed, or deleted.
- During a declared change freeze, the change is prepared and reviewed but merged only after the approval channel decides. The MR or ticket says so and links the approval thread.

## Validation

- No apply, deploy, or production write ran without approval given for this task in this turn.
- The handover contains a copy-ready command block and the target account or context it runs against.

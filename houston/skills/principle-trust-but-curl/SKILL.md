---
name: principle-trust-but-curl
description: "Apply when a value, label, limit, tag, architecture, or vendor behavior is about to be written into code, an alert, a doc, or a decision. Check every fact against the live system before you build on it."
disable-model-invocation: true
---

# Trust but curl

Check every fact against the live system before you build on it.

**Why:** Tags, comments, old docs, and memory drift from reality. A query that matches nothing or an alert that never fires looks exactly like a working one until the incident.

## Output Requirements

- Label names and values come from the metrics API, not from cloud tags or naming conventions. Every query is run and returns plausible series before it ships.
- Architecture, tag existence, and image contents are read from the registry manifest of the exact tag, never from a comment or a filename suffix.
- Vendor limits and capabilities (quotas, whether a feature can be enabled after creation) are checked in current official docs before they become a claimed cost or blocker.
- Before codifying a change you only proposed, read the live state. Someone may already have applied it by hand.
- Verification runs on the real path (an in-cluster Job, the real endpoint), not through a workstation tunnel such as port-forward, unless the endpoint is only reachable that way.

## Reference

- **Bad:** alert on `app="gitlab"` because the instance tag says `Service=gitlab`.
- **Good:** query `/api/v1/label/app/values`, find the relabeled value, and confirm the expression returns one series.

## Validation

- Every label, tag, version, or limit in the change has a command or doc link that produced it.
- Every query in an alert, panel, or report was executed and returned the expected series.

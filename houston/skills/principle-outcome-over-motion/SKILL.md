---
name: principle-outcome-over-motion
description: "Apply when a change is a means to an end, such as a CVE fix, a compatibility fix, or a recommended setting. Confirm that a change actually delivers the goal it was made for, and report what it does not cover."
disable-model-invocation: true
---

# Outcome over motion

Confirm that a change actually delivers the goal it was made for, and report what it does not cover.

**Why:** An image-only patch outside the supported release, or one component bumped out of step with its server, looks like progress and creates drift or breakage.

## Output Requirements

- Security fixes ship through a supported upstream release that contains the fix. Components with only a patched image are reported as waiting, not patched ad hoc.
- Version-coupled components (agent and server, client and control plane) move together, not alone.
- The fixed dependency or binary version is checked in the shipped artifact.
- Anything the change does not fix is stated in the final report.

## Validation

- The shipped artifact contains the fixed version, checked in the artifact itself.
- The final report names what the change does not cover.

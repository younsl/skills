---
name: principle-no-secrets-in-argv
description: "Apply when a task needs a password, token, or registry credential on a remote host, pod, or Job. Move credentials only through stdin or a short-lived scoped object, and leave nothing behind."
disable-model-invocation: true
---

# No secrets in argv

Move credentials only through stdin or a short-lived scoped object, and leave nothing behind.

**Why:** argv, pod specs, and files end up in process lists, manifests, and logs. Temporary access that is not removed becomes permanent access.

## Output Requirements

- Secrets are piped through stdin (`read -r VAR`), never passed as arguments, env in a spec, or written to disk.
- A registry or DB credential for a one-off Job is a minimal Secret with only the needed entries, deleted with the Job.
- Temporary permission rules or grants are scoped to the exact command and removed right after use.
- Tokens, cookies, and customer identifiers are stripped from reports and files.

## Validation

- No secret value appears in shell history, a manifest, a file, or the report.
- Temporary credentials and grants created for the task are deleted, and the report says so.

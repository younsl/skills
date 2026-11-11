---
name: principle-air-gap
description: "Apply when writing to a public repo, PR, issue, or skill, or writing internal docs, tickets, or MRs about work that came from a public project. Keep public and internal content apart in both directions."
disable-model-invocation: true
---

# Air gap

Keep public and internal content apart in both directions.

**Why:** Internal identifiers in public history cannot be fully removed, and public personal sources in internal records confuse ownership.

## Output Requirements

- Public artifacts (files, commits, PR bodies, screenshots, diagrams) carry no internal ticket keys, hostnames, account IDs, repo names, or people.
- Internal artifacts describe sources neutrally and do not name personal repos or public personal registries.
- Public mirrors of internal work are sanitized: internal registries replaced by public origins, internal environment lists and accounts removed.
- Screenshots are checked for what they show before they go anywhere public.

## Validation

- A grep of the public artifact finds no internal hostnames, ticket keys, account IDs, repo names, or people.
- Screenshots and diagrams were reviewed for the same before publishing.

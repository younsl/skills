---
name: principle-source-of-truth
description: "Apply when creating a design doc, slide deck, dashboard, alert, guide, or record of cleanup work. Put each artifact where its team maintains it, and keep exactly one home per artifact type."
disable-model-invocation: true
---

# Source of truth

Put each artifact where its team maintains it, and keep exactly one home per artifact type.

**Why:** A design doc in a chat artifact or a dashboard in the wrong system is invisible to the next maintainer and drifts from the real one.

## Output Requirements

- Design docs and decks live in the repo's docs directory in its existing format, not in a hosted chat artifact.
- Alerts are code. Team-owned dashboards live where the team edits them. When the request does not say, ask.
- Long READMEs stop growing: details go to a docs file and the README keeps a one-line link. Small records stay one line in the README.
- Edits to an artifact are made in its source of truth, never by republishing a copy elsewhere.

## Validation

- The artifact lives in the location its owning team edits.
- There is exactly one copy, and other places link to it.

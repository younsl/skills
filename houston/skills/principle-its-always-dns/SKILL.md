---
name: principle-its-always-dns
description: "Apply when an analysis, impact assessment, incident report, or recurring report is requested. Answer \"what happened\" with numbers measured for this window, layer by layer, not with a template or a guess."
disable-model-invocation: true
---

# It's always DNS

Answer "what happened" with numbers measured for this window, layer by layer, not with a template or a guess.

**Why:** Reusing last week's report with new dates is fabrication, and an unbounded investigation burns the time the question was meant to save.

## Output Requirements

- Reports reuse a previous structure, never its numbers. Every figure is queried and computed for the requested window.
- When the data location is not obvious, ask once instead of substituting.
- Impact analysis compares equal-length windows before and after the change. Extra baselines or wider scans are offered in one line, not run.
- Each claim carries a number, and anything unconfirmed is labeled an estimate with the check that would confirm it.
- Every layer between caller and datastore is measured or marked as not measured, never inferred.

## Validation

- Every number in the report has the query or command that produced it, for the requested window.
- Each layer on the request path is either measured or marked as not measured.

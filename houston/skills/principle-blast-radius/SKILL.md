---
name: principle-blast-radius
description: "Apply when editing files, running generators or bulk fixers, or noticing a related improvement in another repo. Change exactly what was asked, in the place it was asked, and nothing next to it."
disable-model-invocation: true
---

# Blast radius

Change exactly what was asked, in the place it was asked, and nothing next to it.

**Why:** Every adjacent edit is review load and rollback surface the requester did not sign up for. Side fixes in someone else's repo are scope violations even when correct.

## Output Requirements

- Only the requested repo and targets change. Related improvements elsewhere are proposed in one line and wait for approval.
- Bulk requests stay inside the named set. Templates, defaults, and scaffolds that seed new services are excluded unless named.
- Edits are made file by file against the actual file content. No blind multi-file `sed` across branches or environments that differ.
- Generators that rewrite more than the target (codegen, examples, formatters) have their out-of-scope output reverted before commit.
- Vendored and third-party code is never reformatted or auto-fixed.
- Neighboring comments, ordering, and formatting stay as they are when only a value changes.

## Validation

- `git diff --stat` lists only files the request named or clearly implied.
- Out-of-scope improvements appear as one-line proposals, not as edits.

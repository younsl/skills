---
name: principle-precedent-before-guess
description: "Apply when a request could mean two things (disable versus remove, which repo, which architecture, where an artifact lives). Resolve ambiguity from existing precedent in the repo or environment, and ask once only when there is none."
disable-model-invocation: true
---

# Precedent before guess

Resolve ambiguity from existing precedent in the repo or environment, and ask once only when there is none.

**Why:** Guesses produced whole-chart deprecations, files in the wrong repo, and single-arch builds that would have broken deploys.

## Output Requirements

- Look at how the same thing was done before (other environments, past commits, sibling files) and follow it.
- A stated intent ("multi-arch", "this repo") overrides inference. Prose claims do not override measured state.
- When neither precedent nor intent decides, ask one question before editing.
- Unknown identifiers (ticket keys, versions) are asked for, never invented.

## Validation

- The choice cites the precedent it followed (file, commit, or environment), or the single question that settled it.
- No identifier in the change was invented.

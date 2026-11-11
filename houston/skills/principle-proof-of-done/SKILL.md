---
name: principle-proof-of-done
description: "Apply when finishing an implementation, before any commit, push, MR/PR, or release. Call work done only with evidence from checks that actually ran after the last edit."
disable-model-invocation: true
---

# Proof of done

Call work done only with evidence from checks that actually ran after the last edit.

**Why:** A formatter run before the last test edit, or a subagent that says "tests pass", has shipped broken builds and skipped release jobs more than once.

## Output Requirements

- The repo's gates (format, lint, test, coverage, codegen diff, chart lint and render) run after the final edit, and auto-fixers run last.
- The report lists each check as passed, failed, or not run with a reason. Nothing pending is pushed.
- Results from subagents or earlier turns are re-verified, not trusted. Prompts that delegate code include the gates as acceptance criteria.
- User-visible changes are made visible: rebuild and restart the local instance and say where to look.
- Evidence travels with the change: test results collapsed in the MR body, a main-versus-branch comparison for refactors.
- Verification is proportional: a no-code change whose gates CI already runs on the same path skips the local loop.

## Validation

- The report lists each gate with passed, failed, or not run and a reason.
- No edit happened after the last gate run.

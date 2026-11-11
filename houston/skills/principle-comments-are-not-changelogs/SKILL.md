---
name: principle-comments-are-not-changelogs
description: "Apply when adding or editing code, config, values files, CI files, or templates. Add a comment only for what the code cannot say, and put history and rationale in the commit or MR."
disable-model-invocation: true
---

# Comments are not changelogs

Add a comment only for what the code cannot say, and put history and rationale in the commit or MR.

**Why:** Rationale comments go stale, leak into generated docs, and blur the line between upstream text and local notes. Reviewers end up deleting them in almost every file type.

## Output Requirements

- New keys get no explanatory comment unless a format requires one (doc annotations), and then one short line.
- No file-header blocks describing change scope, no version-requirement notes, no change history.
- Existing comments, upstream or not, are left as they are unless the request is about them. Comments that only restate a changed value are removed with it, short label comments stay.
- Comment density matches the file being edited.

## Validation

- The diff adds no comment that narrates the change, restates a key, or records history.
- Comment density of each edited file is unchanged.

---
name: principle-3am-reader
description: "Apply when writing MR bodies, tickets, docs, alerts, bot messages, or diagrams. Write so a tired reader cannot misread it on the first pass."
disable-model-invocation: true
---

# 3am reader

Write so a tired reader cannot misread it on the first pass.

**Why:** Shorthand that reads as a date, vague scope, bare links, and crowded figures all cost a second read when the reader has the least patience.

## Output Requirements

- Notation has one reading: counts in words, HTTP codes with reason phrase, dates with weekday where the convention asks, no fraction shorthand.
- Scope sentences name the full subject: source and target versions, resource types, and audience role.
- Links sit on a keyword. References to other repos use full URLs.
- One message per figure, titled with the message as a sentence. Workflow diagrams show only the core steps.
- When answering someone's question, quote the original verbatim before paraphrasing.
- Bot and notification copy is a full sentence with a subject and verb, not a label.

## Validation

- No notation in the text can be read two ways, and every link sits on a keyword.
- Each figure carries one message and a title that states it.

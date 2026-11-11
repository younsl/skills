### Tool change

A feature, bug fix, or performance change in a tool or service codebase.

1. Bug fix: reproduce it on the same surface the user saw before touching code. Feature: name the data shape first.
2. Find the root cause with runtime evidence. A guard is a fix only when the state it handles is legitimate.
3. Write the change with the domain skill for the language (**rust-generator**, **bash-generator**, **dockerfile-generator**). Prefer code defaults and runtime detection over new config keys (**principle-no-new-knobs**).
4. Run the repo's gates after the last edit (**principle-proof-of-done**). Performance claims follow **principle-before-and-after**.
5. User-visible changes: rebuild, restart the local instance, and recapture affected screenshots (**principle-close-the-loop**).
6. Run Shipping, or Release when the change ships as a new version.

**Reply:** what changed for the user, the repro before and after, the gate results, and anything left for a follow-up.

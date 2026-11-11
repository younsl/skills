### Tool change

A feature, bug fix, or performance change in a tool or service codebase.

1. Bug fix: reproduce it on the same surface the user saw before touching code. Feature: name the data shape first.
2. Find the root cause with runtime evidence. A guard is a fix only when the state it handles is legitimate.
3. Write the change with the domain skill for the language or surface (**go-generator**, **rust-generator**, **bash-generator**, **web-ui**, **mcp-server**, **dockerfile-generator**). Prefer code defaults and runtime detection over new config keys (**principle-no-new-knobs**).
4. Run the repo's gates after the last edit (**principle-proof-of-done**). Performance claims follow **principle-before-and-after**.
5. User-visible changes: rebuild, restart the local instance, and recapture affected screenshots (**principle-close-the-loop**).
6. Schema changes: take the next migration number and seed IDs from the default branch and the target database right before applying, and again right before the MR. The schema lands before the code that needs it. A database another team owns gets the file and a request (**principle-make-before-break**, **principle-no-friday-deploys**).
7. A feature that spans repos lands in dependency order (IaC and permissions, schema, API, web, agent bindings), and every MR links its siblings (**principle-close-the-loop**).
8. Run Shipping, or Release when the change ships as a new version.

**Reply:** what changed for the user, the repro before and after, the gate results, and anything left for a follow-up.

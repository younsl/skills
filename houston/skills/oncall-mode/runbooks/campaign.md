### Campaign

The same change across many repos or services that other teams own, such as a build architecture switch, a dependency mirror switch, or a chart standard.

1. Build the target list from the tracking document or a live inventory, not from memory. Record each target's owner, the branch the change must target, and whether it is in scope (**principle-trust-but-curl**).
2. Prove the change on one representative target end to end, pipeline included, before fanning out (**principle-proof-of-done**).
3. Keep every unit the same shape: branch name pattern, title, label, and body structure, with each team's own context. Edit each target against its own files, never with a blind bulk rewrite (**principle-blast-radius**, **principle-no-snowflakes**).
4. Check each unit's target branch against the tracking document right before opening it. A wrong target branch is the most common campaign mistake.
5. Ship in batches per team through Shipping. A pipeline that fails because your account cannot clone or run in that project is reported as an access issue, not a CI failure.
6. Update the tracking document after each batch with the MR link, status, blocker, and owner (**principle-close-the-loop**).
7. List out-of-scope and blocked targets with the reason (for example a bundled binary built for one architecture only), never skip them silently (**principle-outcome-over-motion**).

**Reply:** counts of targets done, open, blocked, and out of scope, the blockers with owners, and the tracking document link.

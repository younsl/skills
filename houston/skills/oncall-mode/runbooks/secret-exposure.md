### Secret exposure

A credential found in plain text in a repo, chart, log, or ticket.

1. Confirm whether the value is still valid and list every place it appears: current files, git history in every branch and tag, mirrors, logs, and tickets. Refer to it by location and fingerprint, never paste the value (**principle-no-secrets-in-argv**).
2. Rotation is the fix. Ask the owner of the issuing system to rotate it, and plan the consumer update so service continues: the new value goes into the secret store first, then consumers reload (**principle-make-before-break**).
3. Move every consumer from the inline value to a secret store reference through the Config change runbook. Carrying the old value over keeps service up, but the item stays open until rotation.
4. History rewrite is cleanup, not remediation, and runs only on the operator's order: on a mirror clone, force push allowed on protected branches only for the push, the replacement list deleted right after, and GitOps controllers hard-refreshed onto the new commits (**principle-measure-twice-rm-once**).
5. After a rewrite every old clone can restore the removed history. Tell everyone with a clone to reclone, and verify from a fresh clone that no ref contains the value.
6. Track each secret as found, moved, rotated, and history cleaned. Mark it rotated only after the old value fails to authenticate (**principle-proof-of-done**).

**Reply:** a table of location, consumers, moved, rotated, and history status per secret, with the evidence that the old value no longer works.

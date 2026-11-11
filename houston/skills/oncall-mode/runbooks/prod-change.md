### Prod change

A production, freeze-period, or approval-gated change, including production data fixes.

1. Identify production by account, profile, or context, never by name.
2. Check for a change freeze or an approval requirement. During a freeze, prepare and review the change, and state in the MR or ticket that it merges only after the approval thread decides (**principle-no-friday-deploys**).
3. Prepare the change through the matching runbook (Config change, IaC change, Chart bump) without applying it.
4. Write the impact statement: what restarts, what rolls out, what traffic changes, and how long it takes.
5. Data changes: prepare the statement, rehearse it in a transaction with rollback, back up the touched rows, and confirm the session points at the intended target. Hand it to the owning team when they own the schema (**principle-measure-twice-rm-once**).
6. Credentials go through stdin or a short-lived scoped object (**principle-no-secrets-in-argv**).
7. Hand the operator the exact commands, the verification command, and the rollback command. Approval covers this change only.
8. After the operator runs it, verify with the same metric or query that defined success.

**Reply:** the change, its impact statement, the handover commands, the approval it waits on, and the verification result once run.

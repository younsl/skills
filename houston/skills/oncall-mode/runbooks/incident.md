### Incident

Something is broken or degraded now. Restore service first, explain it second.

1. State impact in numbers: what is failing, for whom, since when, at what error rate or latency.
2. Find the most recent change on the affected path (deploys, config, infra, upstream). A change inside the window is the first suspect.
3. Propose the fastest safe mitigation (rollback, scale, failover, feature off) as an exact command. Production actions are the operator's button (**principle-no-friday-deploys**).
4. After mitigation, confirm recovery with the same metric that showed the impact.
5. Run the Investigation runbook for the root cause.
6. Write the postmortem with the Docs runbook: timeline, impact, root cause, contributing factors, and action items that change structure rather than people.
7. Track each action item as its own change through the matching runbook.

**Reply:** current status, impact numbers, mitigation and its evidence, root cause or the open question, and the action item list.

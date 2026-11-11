### Migration

Replacing a collector, architecture, registry, schema, or version that live traffic depends on.

1. Write down the old path, the new path, every consumer of the old path, and how parity will be measured.
2. Land prerequisites first: permissions, agreements, schema, multi-arch builds (**principle-make-before-break**).
3. Run the new path in parallel under a distinguishable name or label. Compare with baseline and diff queries for the same window (**principle-before-and-after**).
4. Images mirror as the full multi-arch index, verified by digest. Each environment's scheduling and registry index is checked before its architecture changes.
5. Cut over per environment, one unit at a time (**principle-reviewable-units**). Recheck the parity query after each cutover.
6. Remove the old path in a separate change, only after every consumer in every environment is confirmed on the new one (Decommission runbook).

**Reply:** the parity evidence before cutover, the cutover status per environment, and what still runs on the old path.

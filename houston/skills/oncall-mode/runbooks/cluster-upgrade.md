### Cluster upgrade

A Kubernetes control plane minor version, a mesh or node agent data plane, or node images and instance types across environments.

1. Read the current and target versions from the live clusters and the provider's release calendar. Plan one minor version per hop (**principle-trust-but-curl**).
2. Inventory every addon and API consumer against the target: removed or deprecated APIs in rendered manifests and live objects, each addon's compatibility matrix, and API features a newer addon release requires. Bump the addons that need it first, through the Chart bump runbook, to versions that support both the current and the target (**principle-make-before-break**).
3. Upgrade the lowest environment first and hold it through a full business cycle before the next. Production goes last, in a low-traffic window, through the Prod change runbook (**principle-reviewable-units**, **principle-no-friday-deploys**).
4. Before rolling node agents or node pools, list what a rolling restart can break: surge pods that preempt others on full nodes, IP or interface capacity per node, agents that restart together and leave a gap, pods that block drains (do-not-disrupt, local storage, budgets), and long jobs or CI agents a drain kills mid-run. Cordon does not stop an idle CI agent from taking new builds, so remove those agent pods before draining.
5. Change node images and instance types through the node pool or launch template definition, never on single nodes by hand. A recreated managed node group loses tags set by hand, so restore them from the group's propagated tags.
6. During and after each environment, watch the same signals for the same window length before and after: edge 5xx rate, container restarts in all namespaces, preemption and sandbox creation events, and node readiness (**principle-before-and-after**).
7. Write the identifying fields of upgrade resources and node pool specs explicitly, even when they equal defaults, so the next upgrade can tell a deliberate off from a missing key (**principle-explicit-beats-clever**).
8. Remove what the upgrade retired (replaced policy engines, compatibility shims) in a separate change through the Decommission runbook. Run Shipping.

**Reply:** versions per environment before and after, the addon compatibility table with what was bumped first, side effects observed with their counts, and the next hop.

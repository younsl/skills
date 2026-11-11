### Onboarding

A new service, job, or tool on the platform: infrastructure, GitOps app, DNS, and exposure.

1. Pick the closest existing service of the same kind (API, consumer, batch, web) as the precedent for every layer, and list what differs (**principle-precedent-before-guess**, **principle-no-snowflakes**).
2. Land the prerequisites in IaC first: image repository, workload identity role with a dedicated policy, security groups, and the datastore or broker rules the service needs, through the IaC change runbook (**principle-make-before-break**).
3. Add the chart values for each environment by copying the sibling's files and changing only values. Create the GitOps app per environment with the sync policy its siblings use.
4. A new hostname needs its DNS record when the cluster runs no DNS controller. External exposure also needs the edge distribution, the web firewall rule set, and any security review the edge requires. Name which layers are managed outside IaC and who owns each.
5. Image pull errors are expected until the first image is built. Say so in the handover instead of chasing them.
6. Once the first image ships, verify end to end: pods ready, the route answering through each entry point, and the workload identity reaching what it needs (**principle-trust-but-curl**).
7. Run Shipping per repo, and link the IaC, GitOps, and ticket changes to each other (**principle-close-the-loop**).

**Reply:** the layers created per environment with their change links, what waits on another owner (first image, security review), and the verification result.

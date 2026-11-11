### Config change

Values, manifests, or policies, often the same change across several environments.

1. Find the precedent: how the same change looks in the environment that already has it (**principle-precedent-before-guess**). Read each target environment's live state and file before editing (**principle-trust-but-curl**).
2. List the exact targets (charts, environments, branches). Templates and scaffolds stay out unless named (**principle-blast-radius**).
3. Edit file by file against each file's actual content. No bulk `sed` across environments that differ. Environments differ only in values (**principle-no-snowflakes**).
4. Prefer reuse, derivation, and defaults over a new key (**principle-no-new-knobs**). Write identifying fields and server defaults explicitly (**principle-explicit-beats-clever**). Use the **helm-chart** or **k8s-manifest** skill for the file type.
5. Render every changed chart before and after with the API versions the cluster serves, and diff the output. State every resource that changes and why (**principle-before-and-after**).
6. Policies roll out in warn or audit first, and deny only after the audit is clean.
7. Ship one environment or branch per unit, finishing each before the next (**principle-reviewable-units**). Run Shipping.
8. After merge, follow the change to the cluster. A GitOps app without automatic sync or prune keeps the old state. A resource kind switch or removal needs a prune sync, and a manual sync carries its sync options explicitly. Hand the sync to the operator on shared clusters, then confirm Synced and Healthy at the new revision (**principle-close-the-loop**).

**Reply:** the change, the rendered diff per environment, live impact (restarts, rollouts, traffic), and what was left out.

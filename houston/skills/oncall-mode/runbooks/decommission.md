### Decommission

Removing a service, stack, chart, environment, or old version.

1. Confirm what "remove" means: disable, deprecate, or delete. Follow precedent, and ask once if none decides it (**principle-precedent-before-guess**).
2. List every consumer and confirm none still depends on it, in every environment (**principle-make-before-break**).
3. Confirm the deletion with the operator unless the request was the destroy order itself (**principle-measure-twice-rm-once**).
4. Destroy through the owning tool (GitOps prune, IaC destroy) rather than by hand, with a plan or diff first.
5. Delete the code, config, and docs that described it in the same flow (**principle-close-the-loop**).

**Reply:** what was removed, the evidence that nothing depended on it, and the leftovers that need another owner.

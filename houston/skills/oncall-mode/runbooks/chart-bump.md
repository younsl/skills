### Chart bump

A chart, app, or image version upgrade.

1. Confirm the target version exists in the registry or chart repo, and read its release notes between the current and target versions (**principle-trust-but-curl**).
2. Follow the **helm-bump** skill. Wrapper values keep the full upstream copy of the pinned version, with only overrides changed (**principle-upstream-is-canon**).
3. Check version coupling: agents and servers, clients and control planes move together (**principle-outcome-over-motion**).
4. Bump every environment the request names, one environment per unit (**principle-reviewable-units**). Render before and after and diff the output.
5. A bump that serves a fix is titled as the fix, with the version after it (**principle-name-the-why**).
6. Run Shipping with a version table and the release notes attached.

**Reply:** from and to versions per environment, breaking changes found in the notes and how they were handled, and the rendered diff summary.

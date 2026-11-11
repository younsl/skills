### Release

Cutting, re-releasing, or promoting a release of a tool you own.

1. Run every gate the release pipeline runs, locally, after the last edit (**principle-proof-of-done**).
2. A performance change ships only after at least two runs of the same benchmark against the previous release build and a happy-path regression run. No gain or any regression means no release (**principle-before-and-after**).
3. Cut the release per the repo's policy (**principle-house-rules**). Same-version re-releases follow the **release-retrigger** skill, toolchain bumps follow **rust-bump-rerelease**. An explicitly invoked re-release runs end to end.
4. Confirm the pipeline result and the published artifacts: every architecture in the image index, the chart, the binaries.
5. Promote with the **release-promote** skill: mirror the image and chart, then bump consumer charts through the Chart bump runbook.

**Reply:** the version, the pipeline link and result, the artifacts verified, and the consumers bumped or still pending.

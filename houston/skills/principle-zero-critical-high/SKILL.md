---
name: principle-zero-critical-high
description: "Apply when writing or changing code, dependencies, lockfiles, Dockerfiles, base images, or release pipelines of an artifact you build, and before any release. Keep known CRITICAL and HIGH vulnerabilities at zero in every artifact you build."
disable-model-invocation: true
---

# Zero critical, zero high

Keep known CRITICAL and HIGH vulnerabilities at zero in every artifact you build.

**Why:** A finding accepted once stays accepted, and the count only grows. Zero is the only threshold that needs no judgment call at release time.

## Output Requirements

- Scope is first-party artifacts: the dependency lockfiles of the source tree and every image or binary the repo builds. Upstream charts and images that are only deployed follow the CVE patch runbook and **principle-outcome-over-motion**.
- Trivy alone decides the verdict, so severity means the same thing in every language. Lockfiles: `trivy fs --scanners vuln --severity HIGH,CRITICAL --exit-code 1 <project dir>`. Images: `trivy image --severity HIGH,CRITICAL --exit-code 1 <image>`. `cargo audit`, `govulncheck`, and `npm audit` add detail and never replace it.
- No exception exists. `--ignore-unfixed`, `.trivyignore`, and VEX suppression are never used, so a finding without a fixed version still fails the scan.
- A finding is fixed at its source: bump the dependency, the toolchain, or the base image, then rescan. Lowering the severity filter, dropping the scan step, or narrowing the scan path is not a fix.
- A new dependency or base image is scanned before it is adopted. One that brings a finding is not added.
- A finding without a fixed version is removed, not waited on: replace or drop the dependency, disable the feature that pulls it in, or switch the base image. When none of these is possible, the artifact is not released and the blocker is reported.
- The release pipeline runs the same scans as a gate before anything is published.
- A scan that did not run is not a pass. It is reported as not run and the work is not release ready.
- Every report states the CRITICAL count and the HIGH count.

## Validation

- Both scans exit 0 after the last edit to a lockfile, Dockerfile, base image, or toolchain pin.
- `grep -rnE 'ignore-unfixed|ignorefile|--vex'` over CI config and scripts returns nothing, and no `.trivyignore` file exists in the repo.

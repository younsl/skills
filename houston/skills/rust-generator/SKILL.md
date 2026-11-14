---
name: rust-generator
description: Write Rust services and CLIs with SRP module layout, 2018-style modules, strict lints, and static multi-arch packaging.
when_to_use: Creating Rust applications, CLI tools, libraries, or async services, e.g. "Rust로 작성", "Rust로 포팅", "에드온 개발". Not for Rust toolchain or MSRV bumps (use rust-bump-rerelease), Dockerfile contents (use dockerfile-generator), release workflows (use github-actions-generator), or chart templates (use helm-chart).
argument-hint: "[project purpose]"
license: Apache-2.0
compatibility: cargo with rustfmt and clippy, plus cargo-zigbuild, zig 0.15.2, and the x86_64 and aarch64 musl targets for addon packaging
metadata:
  version: "1.6.1"
  category: generator
  related: dockerfile-generator helm-chart github-actions-generator done-check rust-bump-rerelease
allowed-tools: Bash(cargo *) Bash(rustc --version) Read Write Edit Grep Glob
user-invocable: true
disable-model-invocation: false
---

# Rust Code Generator

## Contents

- [Output Requirements](#output-requirements)
- [Project Structure (SRP)](#project-structure-srp)
- [Workspace](#workspace)
- [Cargo.toml](#cargotoml)
- [CRD Generation](#crd-generation)
- [Build-Time Metadata](#build-time-metadata)
- [Async Patterns](#async-patterns)
- [Packaging](#packaging)
- [Validation](#validation)

## Output Requirements

- Edition 2024; `rust-version` = the local stable toolchain (`rustc --version`) in full semver (`"x.y.z"`, never `"x.y"`), matching sibling crates in the repo. Bumping an existing project's `rust-version` belongs to rust-bump-rerelease
- `unsafe_code` forbidden via `[lints.rust]`
- Clippy lints: `all`, `pedantic`, `nursery` as warnings
- Errors: `thiserror` enums per layer, `anyhow` only in `main.rs` and the orchestration loop, never in layer directories
- SDK error wrappers (`kube::Error`, AWS SDK errors) live in their layer, e.g. `k8s/error.rs`. Root `error.rs` holds config and domain errors only
- Async runtime: `tokio`
- Logging: `tracing` + `tracing-subscriber`
- CLI: `clap` derive API, config flags fall back to env vars via `env`
- TLS: rustls only (`rustls-tls` features), no `openssl-sys` or `native-tls` in `Cargo.lock`
- Module style: sibling file pattern (`parent.rs` + `parent/`), never `mod.rs`
- CRDs validate with schema bounds and CEL (`KubeSchema`, `x_kube(validation)`), defaults declared in the schema; no validating webhook
- Operators and watchers use `kube::runtime`: `Controller` with `reconcile` and `error_policy`, reflector `Store`, `.owns()`, `Action::requeue`, server-side apply. No hand-rolled watch loops, and a `finalizer` only when ownerReferences cannot cover cleanup
- Every HTTP endpoint has `#[utoipa::path]` and is registered in the `ApiDoc` `paths()` and `schemas`

## Project Structure (SRP)

Split by domain responsibility. Each layer directory owns its API calls and SDK error types. `main.rs` may construct clients to wire them in.

```
src/
├── main.rs           # Orchestration only
├── config.rs         # Config loading and validation
├── error.rs          # Config and domain errors, no SDK types
├── types.rs          # Shared domain types
├── aws.rs            # Declares aws/ submodules
├── aws/
│   ├── error.rs
│   └── <service>.rs
├── k8s.rs
├── k8s/
│   ├── error.rs
│   └── leader.rs
├── observability.rs
└── observability/
    ├── metrics.rs
    └── server.rs
```

| Directory | Responsibility | External deps |
|-----------|---------------|---------------|
| root | Shared domain logic, config, wiring | no client SDK crates beyond client construction in `main.rs` |
| `aws/` | AWS API communication | `aws-sdk-*` |
| `k8s/` | Kubernetes API communication | `kube`, `k8s-openapi` |
| `observability/` | Metrics exposition and HTTP | `prometheus`, `axum` |

## Workspace

A component that ships several crates (two binaries over a shared library, such as an operator and its node agent) is one [Cargo workspace](https://doc.rust-lang.org/cargo/reference/workspaces.html). A component with one crate stays standalone, and a repository never gets a root workspace across unrelated components.

```
<component>/
├── Cargo.toml        # Virtual manifest, no [package]
├── Cargo.lock        # The only lockfile
├── crates/
│   ├── operator/     # Binary crate, with its Dockerfile
│   ├── agent/        # Binary crate, with its Dockerfile
│   └── common/       # Shared library, publish = false
├── charts/
├── docs/
└── Makefile
```

- Every member sits in `crates/<name>/`. The component root holds only the virtual manifest, the lockfile, and the non-Rust directories
- `members` lists each crate explicitly, one per line. No `crates/*` glob
- `resolver = "3"` is set explicitly, because a virtual manifest has no edition to derive it from
- `[workspace.package]` owns `edition`, `rust-version`, `authors`, `license`, and `repository`, inherited with `.workspace = true`. It also owns `version` when the crates release together, so they cannot drift apart. A member that ships as its own image on its own schedule declares its own `version`
- A second binary that uses none of the first one's library, or carries its own version, is its own member, not a `[[bin]]` in the same package. A `[[bin]]` in one package is for binaries that share the library and the version (a `crdgen` beside its controller)
- Code two members share (log format, shutdown signal, build version) lives in a `common` member. A test helper another member needs sits behind a `testing` feature that the dependent enables in `[dev-dependencies]`
- `[workspace.dependencies]` declares every dependency version once, the shared path crate included. Members write `name.workspace = true` and add only the features they need (`tokio = { workspace = true, features = [...] }`)
- `[workspace.lints]` holds the lint tables and members carry `[lints] workspace = true`. A member cannot add to inherited lints, so a crate-wide allow moves to the workspace with its one-line reason
- `[profile.release]` exists only in the root manifest. Cargo ignores profiles in member manifests
- One `Cargo.lock` and one `target/` at the workspace root. Scripts and CI read the build directory from `cargo metadata` (`.target_directory`) instead of assuming `target/` beside the crate
- Each image keeps its Dockerfile in its own crate directory, and the coverage gate runs per binary crate (`cargo llvm-cov -p <crate>`), not on the workspace total
- Paths from a crate to component files (chart CRDs, examples) climb two levels from `CARGO_MANIFEST_DIR`

| Member manifest | Workspace root manifest |
|-----------------|-------------------------|
| `name`, `description`, targets (`[lib]`, `[[bin]]`) | `version`, `edition`, `rust-version`, `license` |
| Dependency names and extra features | Dependency versions and base features |
| `[lints] workspace = true` | Lint tables, `[profile.release]`, `resolver` |

## Cargo.toml

```toml
[lints.rust]
unsafe_code = "forbid"

[lints.clippy]
all = "warn"
pedantic = "warn"
nursery = "warn"

[profile.release]
lto = true
codegen-units = 1
strip = true
panic = "abort"
```

## CRD Generation

Applies to crates that define a `#[derive(CustomResource)]` type. Priority order: generated from code, drift-checked, kept out of the runtime binary. This is the only accepted layout, new crates and migrations of existing ones alike.

- Chart CRD YAML is generated from the Rust types, never hand-written
- Generation runs in a separate `crdgen` binary (`[[bin]] crdgen`, `src/bin/crdgen.rs`, `doc = false`) over a `[lib]`, following kube-rs `controller-rs`. The runtime binary has no `crd` subcommand
- Rendering is Rust only: a lib `render()` wraps the generated `spec` (via `serde_yaml`, descriptions with line breaks collapsed) in the chart's `crds.install` conditional and label helpers, and `crdgen` writes it to the chart path itself. No Python or shell pipe, so `make crd` is `cargo run --bin crdgen`
- Never a Python, PyYAML, `yq`, or other external render script (`scripts/render-crd.py`), and never JSON printed to stdout for another tool to wrap. The Rust toolchain alone regenerates the chart
- The release builds `--bin <name>` and the image copies only that binary, so `crdgen` never ships
- `default-run = "<name>"` in `[package]`, so plain `cargo run` and Makefile targets still pick the controller
- An integration test (`tests/crd_drift.rs`) compares each chart file with `render()` as an exact string and fails with "run `make crd`". It runs in `cargo test`, so pre-commit and the release test job catch a stale chart without a workflow step
- `make install` pins `--bin <name>` so `crdgen` is never installed
- The lib exposes only what the binaries and tests import: the CRD module and one entry such as `start()`, with the former `main` body in a private `app` module. Other modules stay private so dead-code warnings keep working. When a wider surface is public, the public-API doc lints that fire crate-wide (`missing_errors_doc`, `missing_panics_doc`, `must_use_candidate`, `too_long_first_doc_paragraph`) are allowed in `Cargo.toml` with a one-line reason, the lint groups at `priority = -1`

| File | Role |
|------|------|
| `src/lib.rs` | Module tree, crate-level `#![allow]` |
| `src/main.rs` | `#[tokio::main]` that calls the lib entry |
| `src/bin/crdgen.rs` | Writes every chart CRD template from `render()` |
| `src/<crd module>/chart.rs` | `render()` and the chart path, shared by `crdgen` and the drift test |
| `tests/crd_drift.rs` | Chart file vs `render()`, exact compare |

## Build-Time Metadata

- `build.rs` injects `BUILD_COMMIT` and `BUILD_DATE` via `cargo:rustc-env`
- Rerun paths come from `git rev-parse --path-format=absolute --git-path HEAD` and the current branch ref, emitted only when they exist. Never a literal `.git/HEAD`: it is missing in a crate below the repo root, so cargo reruns every build

## Async Patterns

- Services: graceful shutdown via `tokio::select!` on `signal::ctrl_c()` and SIGTERM. One-shot CLIs exit on either signal
- Concurrency: `JoinSet` + `Semaphore` for bounded parallelism

## Packaging

- New Kubernetes addons are Rust in `box/addons/<name>/`: Makefile `zigbuild` target builds static musl binaries for amd64 and arm64 with cargo-zigbuild, shipped in a `scratch` image (see dockerfile-generator) with a chart at `box/addons/<name>/charts/<name>/` (see helm-chart)
- A new addon or CLI joins its release workflow and detect list per github-actions-generator. Unregistered projects never ship
- CLIs live in `box/cli/<name>/` and release through `_release-rust-cli.yml`, no Dockerfile or chart. When no repo is named, state the location assumed
- Comments follow the global Code Comments rule; public items get doc comments only when behavior is not obvious from the signature

## Validation

- done-check Rust gate passes (`cargo fmt --check`, `cargo clippy --all-targets -- -D warnings`, `cargo test`)
- Glob `src/**/mod.rs` returns nothing
- Every route on the axum router appears in the generated OpenAPI document
- A second `cargo build -v` reports `Fresh` for the crate
- `Cargo.lock` has no `openssl-sys` or `native-tls` package
- Addons: `make zigbuild` produces both musl binaries
- Workspaces: no `Cargo.lock`, `[profile.*]`, or lint level below `crates/`, no member manifest pins a dependency version, and `cargo metadata` reports every member under `crates/`
- CRD crates: `--help` of the runtime binary lists no `crd` command, and editing a chart CRD field makes `cargo test --test crd_drift` fail
- CRD crates: no `render-crd.py` or other non-Rust render script exists, the `make crd` recipe is only `cargo run --bin crdgen`, and running it on a clean tree leaves `git status` clean

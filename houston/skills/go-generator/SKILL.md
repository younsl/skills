---
name: go-generator
description: Write Go services, CLIs, and controllers with the user's formatting loop, logging, metrics, config, and API documentation conventions.
when_to_use: Creating or changing Go code in a service, CLI, controller, or upstream Go project, e.g. "Go로 작성", "API 엔드포인트 추가", "메트릭 추가", "로그 메시지 정리", "gofmt, go fix 적용". Not for Rust (use rust-generator), Dockerfiles (use dockerfile-generator), MCP server design (use mcp-server), web frontends (use web-ui), or the verification gate alone (use done-check).
argument-hint: "[package or feature]"
license: Apache-2.0
compatibility: go toolchain matching go.mod, gofmt, go vet, plus docker or podman for Linux-only tests on macOS
metadata:
  version: "1.0.0"
  category: generator
  related: done-check dockerfile-generator mcp-server web-ui helm-chart
allowed-tools: Bash(go *) Bash(gofmt *) Bash(make *) Bash(docker run *) Bash(podman run *) Bash(curl *) Bash(lsof *) Read Write Edit Grep Glob
user-invocable: true
disable-model-invocation: false
---

# Go Code Generator

Standard Go practice (wrapped errors, context first, table tests, no package-level mutable state) applies without restating it. Below are the conventions that differ from defaults or were corrected before.

## Output Requirements

### Formatting

- `gofmt -w` on changed packages, then `go fix ./...` repeated until `go fix -diff ./...` prints nothing, after the last edit. Fixer rewrites can chain, so one pass is not enough
- Vendored, generated, and third-party code is never formatted or fixed. Fixer output outside the task's packages is reverted
- Delegated Go work carries the gofmt and go fix loop as an acceptance check

### Comments

- No file header block describing change scope, origin, or authorization model. That belongs in the MR
- Doc comments stay short, in the codebase's existing language

### Logs

- `log/slog` messages in short lowercase plain English with common words (`secret scan started`, `could not save progress`)
- Durations as human-readable strings (`time.Since(start).Round(time.Millisecond).String()`), never integer nanoseconds
- User-facing error text (API error bodies, UI messages, rows saved for users) stays in the product's language. Logs are not user-facing
- Existing log lines are mass-rewritten only on request

### Metrics

- Prometheus `Help` strings in English
- Label names avoid scrape target labels: `cluster`, `container`, `endpoint`, `instance`, `job`, `namespace`, `pod`, `service`. With `honor_labels` off they arrive as `exported_<name>` and break every `by (...)` query
- Metrics served on a dedicated listener and port, separate from traffic
- A new metric is done only after its real series and labels are read back from the metrics backend after deploy

### Configuration

- Reuse a value another config block already holds (an endpoint, a tenant) and detect environment facts at runtime (cluster identity from the API) before adding a key. State the detection path in the endpoint description and the MR
- Config YAML comments are one line above the key, `# -- (type) description`. No trailing inline comments, no multi-line blocks
- Maps in config YAML are block style, never `{}` flow style

### API

- Every HTTP endpoint is registered in the OpenAPI document with request and response schemas. Gaps found next to the change are filled in the same change
- Long-running jobs survive a pod restart: progress is persisted before each step and the job reattaches on start

### Layout

- One module unless the repo is imported as a library. A second image comes from a second Dockerfile, not a second module
- Container binaries are static (`CGO_ENABLED=0`), built in CI, and copied into the image (dockerfile-generator)

## Local Runs

- Local instances run on high ports from a config copy outside the repo, never by editing tracked config. Stop them by your own port (`lsof -tiTCP:<port>`), never by a process-name pattern that can hit other sessions
- Killing `go run` can leave the child binary listening. Check the port is free before a smoke test
- Tests that need Linux interfaces (`/proc`, cgroups) run in a `golang` container matching `go.mod`, with `-race`

## Validation

- `gofmt -l <changed dirs>` prints nothing
- `go fix -diff ./...` prints nothing
- `go vet ./...` and `go test ./...` pass, with `-race` where the repo uses it
- New `Help` strings are English and new label names are outside the reserved list

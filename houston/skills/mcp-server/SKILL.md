---
name: mcp-server
description: Design and ship MCP servers that expose a platform's API to AI agents, and bind their tools to agents, following the user's packaging, auth, metrics, and binding conventions.
when_to_use: Adding an MCP server or new MCP tools, exposing an existing API to agents, or binding tools and prompts to an agent runtime, e.g. "MCP 서버 추가", "MCP 툴 추가", "에이전트에 툴 바인딩", "kagent 연동", "RemoteMCPServer 추가". Not for the service's own business logic (use go-generator or rust-generator), chart template structure (use helm-chart), or the alert rules agents react to (use promql-generator).
argument-hint: "[upstream API or tool group]"
license: Apache-2.0
compatibility: the official MCP SDK for the language, an MCP client for smoke tests, helm for rendering bindings
metadata:
  version: "1.0.0"
  category: generator
  related: go-generator rust-generator helm-chart k8s-manifest
allowed-tools: Bash(go *) Bash(cargo *) Bash(helm *) Bash(kubeconform *) Bash(curl *) Read Write Edit Grep Glob
user-invocable: true
disable-model-invocation: false
---

# MCP Server

## Output Requirements

### Shape

- The MCP server is its own binary, image, version, and pod, not a plugin inside the upstream app. Tool changes release without rebuilding the app
- Same repo and module as the app unless the repo is a library. The MCP image gets its own Dockerfile and release workflow
- A stateless proxy: each tool call maps to one upstream API request, with no business logic or cache in the MCP layer
- Official SDK for the language, streamable HTTP transport at `/mcp`
- Tool names carry a product prefix (`<product>_<verb>_<noun>`). Agent runtimes do not prefix tool names by server, so two servers with equal tool names cannot share one agent
- Tools are read-only by default. A write tool exists only on request and says it writes in its name

### Auth

- The caller's `Authorization` header is forwarded upstream so the upstream's RBAC decides per caller. A service token is a fallback only
- Upstream endpoints the MCP calls accept a service principal on read routes only
- OAuth login uses two identity provider clients: a public client with PKCE and a fixed local callback port for the user's tool, and a bearer-only client that names the API audience

### Runtime

- Metrics on their own listener and port: tool calls by tool and outcome (`ok`, `tool_error`, `error`), tool duration, and upstream requests by method and status
- Sessions live in pod memory, so one replica unless the route has session affinity
- Tool and argument doc comments become the JSON schema descriptions the agent reads. Write them for the agent, and allow the lint that fights that

### Chart

- An `mcp` block in the app chart, disabled by default, with its own image block whose tag does not default to the app version
- MCP templates live in their own directory beside the app's templates
- External exposure (ingress or gateway route) only when an agent in another cluster must reach the server

## Agent Binding

- Every MR that adds tools ships with a paired binding MR in the GitOps repo. The tool MR names the binding as a required follow-up, merged only after the server with those tools is deployed
- Respect the agent resource's tool count limit per server entry. Split one server into several entries when it overflows
- Bind only the tools an agent's role needs. Environment-scoped agents bind environment-scoped tools
- An agent's prompt has one source, its system message. Other places that need the contract carry a one-line pointer, never a copy, and never an empty value that falls back to a built-in prompt
- Agents that answer in non-interactive channels have interactive ask-the-user tools removed
- An unreachable MCP server can fail the whole agent run. Confirm every bound server answers before enabling a binding

## Validation

- Through the deployed endpoint: list tools, call one read tool with a real caller token, and call it once without a token to see the denial
- `helm template` of the binding renders, and every server entry is under the tool count limit
- The metrics endpoint shows the tool call counter after the smoke test

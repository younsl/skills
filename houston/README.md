# houston

SRE skill stack for Claude Code. Start any engineering or operations task with `/houston:oncall-mode`. It restates the goal, triages the task into one of 15 runbooks, applies the principle skills each step cites, and hands back a verified result with its evidence.

## Install

```console
/plugin marketplace add younsl/skills
/plugin install houston@younsl
```

## Contents

- `skills/oncall-mode/`: the entry skill and its `runbooks/`.
- `skills/principle-*/`: engineering principles such as trust-but-curl, proof-of-done, blast-radius, and no-friday-deploys.
- `skills/<name>/`: domain skills for Helm, Kubernetes manifests, Terraform, PromQL, Falco, CI, Dockerfiles, Bash, Rust, releases, Jira, and writing.
- `agents/flight-controller.md`: the delegate subagent oncall-mode spawns inside a runbook step.

Production writes, applies, deletes, and messages to people always pause for the operator. See the [repository README](https://github.com/younsl/skills) for development and checks.

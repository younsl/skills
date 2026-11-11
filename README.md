# skills

[![Check](https://img.shields.io/github/actions/workflow/status/younsl/skills/check.yml?branch=main&label=check&style=flat-square&color=black)](https://github.com/younsl/skills/actions/workflows/check.yml)
[![License](https://img.shields.io/github/license/younsl/skills?style=flat-square&color=black)](LICENSE)

Claude Code skill stacks for SRE work, written in the [Agent Skills](https://agentskills.io) format and shipped as a plugin marketplace.

## houston

Houston, we have a task. [houston](houston) is an SRE skill stack modeled on [pstack](https://github.com/cursor/plugins/tree/main/pstack). One entry skill acks every task, triages it into a runbook, and lands it verified.

```
houston/
├── skills/
│   ├── oncall-mode/          entry skill and its runbooks/
│   ├── principle-*/          24 engineering principles
│   └── <domain skills>/      helm-chart, k8s-manifest, terraform-generator, ...
└── agents/
    └── flight-controller.md  delegate subagent used inside a runbook
```

- **oncall-mode** restates the goal, picks one of 15 runbooks (Investigation, Incident, Config change, IaC change, Prod change, Chart bump, CVE patch, Release, Migration, Alerting, Right-sizing, Decommission, Tool change, Docs, Shipping), and copies its steps into a todo list.
- **principle-\*** skills carry the rules each runbook step cites, such as `principle-trust-but-curl` (check every fact against the live system), `principle-no-friday-deploys` (production is the operator's button), and `principle-its-always-dns` (measure each layer instead of guessing).
- **Domain skills** hold the conventions for one file type or tool, such as Helm charts, Terraform, PromQL, Dockerfiles, and Rust.

## Install

From the marketplace:

```console
/plugin marketplace add younsl/skills
/plugin install houston@younsl
```

From a local clone, so edits load without reinstalling:

```console
$ scripts/install.sh   # links ~/.claude/skills/houston to this checkout
```

Then run `/reload-plugins` and start a task with `/houston:oncall-mode`. Domain skills also work on their own, for example `/houston:helm-chart`.

## Development

```console
$ scripts/check.sh
```

The check validates the marketplace and plugin manifests, the frontmatter and size of every skill, that every principle skill starts with `principle-` and is listed in oncall-mode, that every runbook and principle oncall-mode references exists, and that no email address, AWS account ID, or private IP outside the example ranges is committed.

## License

[Apache License 2.0](LICENSE)

## AI Disclosure

The entire codebase of this project was developed with the assistance of [Claude Opus 5.5](https://www.anthropic.com/claude/opus) (High effort).

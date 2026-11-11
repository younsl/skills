# AGENTS.md

Claude Code plugin marketplace. The `houston` plugin is an SRE skill stack: `oncall-mode` routes tasks to runbooks, `principle-*` skills hold the rules, domain skills hold file-type conventions.

## Layout

- `.claude-plugin/marketplace.json`: marketplace `younsl`
- `houston/skills/oncall-mode/`: entry skill, `runbooks/*.md`
- `houston/skills/principle-*/`: one principle per skill
- `houston/skills/<name>/`: domain skills
- `houston/agents/`: delegate subagents
- `houston/hooks/`: `guard.sh` PreToolUse guard, wired in `hooks.json`
- `houston/skills/<name>/scripts/`: executables a skill owns, such as `terraform-generator/scripts/tf-safe-apply`
- `scripts/`: `check.sh` (validation), `test-guard.sh` (guard cases), `install.sh` (local link), `skill-toc.py` (Contents for long skills)

## Rules

- SRE principle skills start with `principle-`. Every principle is listed under oncall-mode Principles, every domain skill under oncall-mode Domain skills
- Principle skills set `disable-model-invocation: true` and are reached through oncall-mode
- Skills are declarative: constraints and validation criteria, not procedures or boilerplate. Runbooks are the exception, because their step order is the content
- Each SKILL.md stays under 500 lines with `name` matching its directory
- Public repo: no company names, internal hosts, ticket keys, account IDs, private IPs, emails, or people. Examples use `example.com`, `10.0.0.0/16`, `123456789012`
- Prose follows the writing-style skill: no em dash, no semicolons, links on keywords
- A safety rule that must hold even when no skill is loaded goes in `houston/hooks/guard.sh` with allow, ask, and deny cases in `scripts/test-guard.sh`. Guard decisions prefer ask over deny unless a safe alternative exists
- Terraform applies go through `tf-safe-apply` only. Never weaken its delete and replace check or the guard rule that enforces it
- Bump `version` in `houston/.claude-plugin/plugin.json` when skill behavior changes
- `scripts/check.sh` passes before every commit. Commits use Conventional Commits with `-s` sign-off

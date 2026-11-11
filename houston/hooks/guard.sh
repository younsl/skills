#!/usr/bin/env bash
# PreToolUse guard for Bash commands. Reads the hook payload on stdin.
set -euo pipefail

command -v jq >/dev/null || exit 0
cmd="$(jq -r '.tool_input.command // empty')"
[[ -n "$cmd" ]] || exit 0

root="${CLAUDE_PLUGIN_ROOT:-$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)}"
wrapper="$root/skills/terraform-generator/scripts/tf-safe-apply"

decision=""
reason=""
raise() {
  local level="$1" text="$2"
  if [[ "$level" == deny || -z "$decision" ]]; then
    [[ "$decision" == deny ]] && return
    decision="$level"
    reason="$text"
  fi
}

nl=$'\n'
segments="${cmd//&&/$nl}"
segments="${segments//||/$nl}"
segments="${segments//;/$nl}"
segments="${segments//|/$nl}"
segments="${segments//\$(/$nl}"
segments="${segments//\`/$nl}"
segments="${segments//)/ }"
while IFS= read -r segment; do
  read -r -a words <<<"$segment" || true
  ((${#words[@]})) || continue
  i=0
  while ((i < ${#words[@]})); do
    case "${words[i]}" in
      *=* | sudo | time | command | exec | env | nohup) ((i += 1)) ;;
      *) break ;;
    esac
  done
  ((i < ${#words[@]})) || continue
  bin="$(basename "${words[i]}")"
  args=" ${words[*]:i+1} "

  case "$bin" in
    tf-safe-apply)
      if [[ "$args" == *" --allow-delete "* ]]; then
        raise ask "tf-safe-apply was given --allow-delete. Confirm each listed address is a deletion the request asked for."
      fi
      ;;
    terraform | tofu | terragrunt)
      if [[ "$args" == *" destroy "* || "$args" == *" -destroy "* ]]; then
        raise ask "Terraform destroy removes resources. Confirm the destruction is intended and the target is correct."
      elif [[ "$args" == *" apply "* ]]; then
        raise deny "Raw $bin apply is blocked by houston. Run $wrapper instead: it applies only the saved plan, stops on any delete or replace not passed with --allow-delete, and verifies a clean plan after apply."
      elif [[ "$args" =~ \ (import|taint|untaint|force-unlock)\  || "$args" =~ \ state\ (rm|mv|push|replace-provider)\  ]]; then
        raise ask "This $bin command changes state outside a reviewed plan. Confirm it is intended."
      fi
      ;;
  esac
done <<<"$segments"

[[ -n "$decision" ]] || exit 0
jq -n --arg d "$decision" --arg r "$reason" \
  '{hookSpecificOutput: {hookEventName: "PreToolUse", permissionDecision: $d, permissionDecisionReason: $r}}'

#!/usr/bin/env bash
# PreToolUse guard for Bash commands. Reads the hook payload on stdin.
set -euo pipefail

payload="$(</dev/stdin)"
root="${CLAUDE_PLUGIN_ROOT:-$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)}"
wrapper="$root/skills/terraform-generator/scripts/tf-safe-apply"
tools='terraform|tofu|terragrunt'

emit() {
  local d="$1" r="${2//\"/\'}"
  printf '{"hookSpecificOutput":{"hookEventName":"PreToolUse","permissionDecision":"%s","permissionDecisionReason":"%s"}}\n' "$d" "$r"
  exit 0
}

tool_word="(^|[^a-z0-9_-])($tools)([^a-z0-9_-]|$)"

if ! command -v jq >/dev/null 2>&1; then
  if [[ "$(tr '[:upper:]' '[:lower:]' <<<"$payload")" =~ $tool_word ]]; then
    emit ask "houston guard cannot parse the command without jq. Confirm this Terraform-family command is safe."
  fi
  exit 0
fi
cmd="$(jq -r '.tool_input.command // empty' <<<"$payload")"
[[ -n "$cmd" ]] || exit 0

decision=""
reason=""
raise() {
  local level="$1" text="$2"
  [[ "$decision" == deny ]] && return
  if [[ "$level" == deny || -z "$decision" ]]; then
    decision="$level"
    reason="$text"
  fi
}

normalized="$(tr -d "'\"\\\\" <<<"$cmd" | tr '[:upper:]' '[:lower:]')"
nl=$'\n'
segments="$normalized"
# shellcheck disable=SC2016
for sep in '&&' '||' '$(' ';' '|' '&' '`' '(' ')' '{' '}' '<' '>'; do
  segments="${segments//"$sep"/$nl}"
done

has_tool=false
[[ "$normalized" =~ $tool_word ]] && has_tool=true
has_danger=false
for token in $(tr -s '[:space:]' ' ' <<<"$normalized"); do
  case "$token" in
    apply | apply-all | destroy | destroy-all | -destroy | -destroy=*) has_danger=true ;;
  esac
done

check_tool() {
  local bin="$1"
  shift
  local w destroy=false apply=false state=false
  for w in "$@"; do
    case "$w" in
      destroy | destroy-all | -destroy | -destroy=true) destroy=true ;;
      apply | apply-all) apply=true ;;
      import | taint | untaint | force-unlock) state=true ;;
    esac
  done
  [[ " $* " =~ \ state\ (rm|mv|push|replace-provider)\  ]] && state=true
  if $destroy; then
    raise ask "Terraform destroy removes resources. Confirm the destruction is intended and the target is correct."
  elif $apply; then
    raise deny "Raw $bin apply is blocked by houston. Run $wrapper instead: it applies only the saved plan, stops on any delete or replace not passed with --allow-delete, and verifies a clean plan after apply."
  elif $state; then
    raise ask "This $bin command changes state outside a reviewed plan. Confirm it is intended."
  fi
}

while IFS= read -r segment; do
  read -r -a words <<<"$segment" || true
  ((${#words[@]})) || continue
  first=0
  while ((first < ${#words[@]})); do
    case "${words[first]}" in
      then | do | else | elif | if | while | until | !) ((first += 1)) ;;
      *) break ;;
    esac
  done
  ((first < ${#words[@]})) || continue
  case "$(basename -- "${words[first]}")" in
    echo | printf | git | gh | glab | grep | rg | cat | sed | awk | jq | yq | curl | man | which | type | less | head | tail | wc | sort | diff | ls) continue ;;
  esac

  before="$decision"
  for ((j = first; j < ${#words[@]}; j++)); do
    bin="$(basename -- "${words[j]}")"
    if [[ "$bin" == tf-safe-apply ]]; then
      for w in "${words[@]:j+1}"; do
        [[ "$w" == --allow-delete* ]] && raise ask "tf-safe-apply was given --allow-delete. Confirm each listed address is a deletion the request asked for."
      done
      break
    elif [[ "$bin" =~ ^($tools)$ ]]; then
      check_tool "$bin" "${words[@]:j+1}"
      break
    fi
  done

  case "$(basename -- "${words[first]}")" in
    eval | bash | sh | zsh | dash | xargs | parallel | watch | ssh | script | find | make | just | task)
      if $has_tool && [[ "$decision" == "$before" ]]; then
        raise ask "A Terraform-family command runs inside ${words[first]}, where houston guard cannot fully see its arguments. Confirm it is not a raw apply or destroy."
      fi
      ;;
  esac
done <<<"$segments"

if [[ -z "$decision" ]] && $has_tool && $has_danger; then
  raise ask "The command mentions a Terraform-family tool together with apply or destroy in a form houston guard cannot verify. Confirm it does not run a raw apply or destroy."
fi

[[ -n "$decision" ]] || exit 0
emit "$decision" "$reason"

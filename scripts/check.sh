#!/usr/bin/env bash
# Usage: scripts/check.sh
set -euo pipefail

cd "$(dirname "${BASH_SOURCE[0]}")/.."
fail=0
err() {
  printf 'error: %s\n' "$*" >&2
  fail=1
}

if command -v claude >/dev/null 2>&1; then
  claude plugin validate . >/dev/null || err "marketplace manifest is invalid"
  claude plugin validate houston --strict >/dev/null || err "houston plugin is invalid (run: claude plugin validate houston --strict)"
else
  err "claude CLI not found, plugin manifests were not validated"
fi

for skill in houston/skills/*/; do
  dir="${skill%/}"
  name="$(basename "$dir")"
  file="$dir/SKILL.md"
  [[ -f "$file" ]] || { err "$dir has no SKILL.md"; continue; }
  [[ "$(sed -n 's/^name: *//p' "$file" | head -n1)" == "$name" ]] || err "$file: frontmatter name must be $name"
  grep -qE '^description: *[^ ]' "$file" || err "$file: description is empty"
  lines="$(wc -l <"$file" | tr -d ' ')"
  (( lines <= 500 )) || err "$file: $lines lines, limit is 500"
done

python3 scripts/skill-toc.py houston/skills/*/SKILL.md >/dev/null || err "skill-toc rewrote a Contents section, review and commit it"

mode=houston/skills/oncall-mode
refs="$(cat "$mode/SKILL.md" "$mode"/runbooks/*.md 2>/dev/null || true)"
while read -r principle; do
  [[ -f "houston/skills/$principle/SKILL.md" ]] || err "oncall-mode references missing skill $principle"
done < <(grep -oE 'principle-[a-z0-9-]+[a-z0-9]' <<<"$refs" | sort -u)
while read -r runbook; do
  [[ -f "$mode/$runbook" ]] || err "oncall-mode references missing $runbook"
done < <(grep -oE 'runbooks/[a-z0-9-]+\.md' <<<"$refs" | sort -u)

section() {
  awk -v h="## $2" '$0 == h {on=1; next} /^## / {on=0} on' "$1"
}
principles="$(section "$mode/SKILL.md" Principles | grep -oE '^- \*\*[^*]+\*\*' | sed -E 's/^- \*\*//; s/\*\*$//; s/\.$//')"
while read -r entry; do
  [[ -z "$entry" || "$entry" == principle-* ]] || err "oncall-mode Principles lists '$entry', principle skills must start with principle-"
done <<<"$principles"
domain="$(section "$mode/SKILL.md" "Domain skills")"
for skill in houston/skills/*/; do
  name="$(basename "$skill")"
  case "$name" in
    oncall-mode | dc) ;;
    principle-*) grep -qxF "$name" <<<"$principles" || err "$name is not listed under oncall-mode Principles" ;;
    *) grep -qF "**$name**" <<<"$domain" || err "$name is not listed under oncall-mode Domain skills" ;;
  esac
done

scan() {
  local label="$1" pattern="$2" allow="$3" hits
  hits="$(git grep --untracked -nIE "$pattern" -- . ':!LICENSE' | grep -vE "$allow" || true)"
  [[ -z "$hits" ]] || err "$label:"$'\n'"$hits"
}
scan "email address outside example.com" '[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[a-z]{2,}' '@(example\.(com|org)|users\.noreply\.github\.com)|git@github\.com'
scan "AWS account id other than 123456789012" '(^|[^0-9])[0-9]{12}([^0-9]|$)' '123456789012'
scan "private IP outside 10.0.0.0/16" '(^|[^0-9.])(10\.[0-9]+|172\.(1[6-9]|2[0-9]|3[01])|192\.168)\.[0-9]+\.[0-9]+' '10\.0\.[0-9]+\.[0-9]+'

if (( fail )); then
  exit 1
fi
echo "ok"

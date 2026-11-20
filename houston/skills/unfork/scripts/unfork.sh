#!/usr/bin/env bash
set -euo pipefail

usage() {
  cat <<'EOF'
Usage: unfork.sh [--dry-run] [--root DIR] [--keep NAME]...

Delete every fork owned by the authenticated gh account that has no open
pull request, on GitHub and in local clones under the root. A fork is kept
when an open pull request uses it as head or base, or when a local clone
holds work that exists nowhere else.

  --dry-run    list what would be deleted, delete nothing
  --root DIR   tree scanned for local clones, 4 levels deep (default: ~/github)
  --keep NAME  fork to leave alone, as name or owner/name (repeatable)

stdout: TSV rows "<action>\t<target>\t<item>\t<note>"
        action: would-delete, deleted, kept, failed
        target: remote, local
stderr: progress and summary
EOF
}

DRY_RUN=0
ROOT="$HOME/github"
KEEP=""

lower() { printf '%s' "$1" | tr '[:upper:]' '[:lower:]'; }

while [ $# -gt 0 ]; do
  case "$1" in
    --dry-run) DRY_RUN=1 ;;
    --root)
      ROOT="${2:?--root needs a directory}"
      shift
      ;;
    --keep)
      KEEP="$KEEP$(lower "${2:?--keep needs a repository name}" | sed 's#^.*/##')
"
      shift
      ;;
    -h | --help)
      usage
      exit 0
      ;;
    *)
      usage >&2
      exit 2
      ;;
  esac
  shift
done

for tool in gh git find awk sed tr sort paste; do
  command -v "$tool" >/dev/null 2>&1 || {
    echo "missing required tool: $tool" >&2
    exit 1
  }
done

TMP=$(mktemp -d)
trap 'rm -rf "$TMP"' EXIT

log() { printf '%s\n' "$*" >&2; }
emit() { printf '%s\t%s\t%s\t%s\n' "$1" "$2" "$3" "${4:-}"; }

tilde() {
  case "$1" in
    "$HOME"/*) printf '%s/%s' '~' "${1#"$HOME"/}" ;;
    *) printf '%s' "$1" ;;
  esac
}

slug_of() {
  printf '%s\n' "$1" |
    sed -nE 's#^.*github\.com[:/]+([^/]+)/([^/]+)$#\1/\2#p' |
    sed 's#\.git$##' | tr '[:upper:]' '[:lower:]'
}

local_blocker() {
  local dir=$1
  case "$PWD/" in
    "$dir"/*)
      echo "is the current directory"
      return 0
      ;;
  esac
  if [ -n "$(git -C "$dir" status --porcelain 2>/dev/null)" ]; then
    echo "uncommitted changes"
  elif [ -n "$(git -C "$dir" stash list 2>/dev/null)" ]; then
    echo "stash entries"
  elif [ -n "$(git -C "$dir" log --branches --not --remotes -n 1 --format=%h 2>/dev/null)" ]; then
    echo "commits not pushed to any remote"
  elif [ "$(git -C "$dir" worktree list --porcelain 2>/dev/null | grep -c '^worktree ')" -gt 1 ]; then
    echo "linked worktrees"
  fi
}

LOGIN=$(gh api user --jq .login)
log "account: $LOGIN"

if [ "$DRY_RUN" -eq 0 ]; then
  scopes=$(gh api -i user 2>/dev/null | tr -d '\r' | awk -F': ' 'tolower($1) == "x-oauth-scopes" { print $2 }')
  case "$scopes" in
    "" | *delete_repo*) ;;
    *)
      log "gh token lacks the delete_repo scope. Run: gh auth refresh -h github.com -s delete_repo"
      exit 1
      ;;
  esac
fi

# shellcheck disable=SC2016
gh api graphql --paginate -f query='
query($endCursor: String) {
  viewer {
    repositories(first: 100, after: $endCursor, isFork: true, ownerAffiliations: OWNER) {
      pageInfo { hasNextPage endCursor }
      nodes {
        name
        nameWithOwner
        parent { nameWithOwner }
        pullRequests(states: OPEN) { totalCount }
      }
    }
  }
}' --jq '.data.viewer.repositories.nodes[]
  | [.name, .nameWithOwner, (.parent.nameWithOwner // "-"), .pullRequests.totalCount] | @tsv' \
  >"$TMP/forks"

# shellcheck disable=SC2016
gh api graphql --paginate -f query='
query($endCursor: String) {
  viewer {
    pullRequests(first: 100, after: $endCursor, states: OPEN) {
      pageInfo { hasNextPage endCursor }
      nodes { url headRepository { nameWithOwner } }
    }
  }
}' --jq '.data.viewer.pullRequests.nodes[]
  | select(.headRepository != null) | [.headRepository.nameWithOwner, .url] | @tsv' \
  >"$TMP/prs"

: >"$TMP/clones"
if [ -d "$ROOT" ]; then
  find "$ROOT" -maxdepth 4 -type d -name .git -prune 2>/dev/null |
    while IFS= read -r gitdir; do
      dir=${gitdir%/.git}
      git -C "$dir" remote -v 2>/dev/null </dev/null | awk '{ print $2 }' | sort -u |
        while IFS= read -r url; do
          slug=$(slug_of "$url")
          [ -z "$slug" ] || printf '%s\t%s\n' "$slug" "$dir"
        done
    done | sort -u >"$TMP/clones"
fi

log "forks: $(wc -l <"$TMP/forks" | tr -d ' '), scanning clones under $(tilde "$ROOT")"

n_delete=0
n_kept=0
n_failed=0

while IFS=$'\t' read -r name nwo parent inbound; do
  key=$(lower "$nwo")
  reason=""

  if printf '%s' "$KEEP" | grep -qxF "$(lower "$name")"; then
    reason="excluded by --keep"
  fi

  if [ -z "$reason" ]; then
    prs=$(awk -F'\t' -v k="$key" 'tolower($1) == k { print $2 }' "$TMP/prs" | paste -sd' ' -)
    [ -z "$prs" ] || reason="open PR from this fork: $prs"
  fi

  if [ -z "$reason" ] && [ "$inbound" -gt 0 ]; then
    reason="$inbound open PR into this fork"
  fi

  awk -F'\t' -v k="$key" '$1 == k { print $2 }' "$TMP/clones" >"$TMP/paths"

  if [ -z "$reason" ]; then
    while IFS= read -r path; do
      blocker=$(local_blocker "$path")
      if [ -n "$blocker" ]; then
        reason="local clone $(tilde "$path") has $blocker"
        break
      fi
    done <"$TMP/paths"
  fi

  if [ -n "$reason" ]; then
    emit kept remote "$nwo" "$reason"
    while IFS= read -r path; do
      emit kept local "$(tilde "$path")" "fork kept"
    done <"$TMP/paths"
    n_kept=$((n_kept + 1))
    continue
  fi

  if [ "$DRY_RUN" -eq 1 ]; then
    emit would-delete remote "$nwo" "fork of $parent"
    while IFS= read -r path; do
      emit would-delete local "$(tilde "$path")" "clone of $nwo"
    done <"$TMP/paths"
    n_delete=$((n_delete + 1))
    continue
  fi

  if gh repo delete "$nwo" --yes </dev/null >/dev/null 2>"$TMP/err"; then
    emit deleted remote "$nwo" "fork of $parent"
    n_delete=$((n_delete + 1))
    while IFS= read -r path; do
      if [ -n "$path" ] && [ -d "$path/.git" ] && rm -rf "$path" 2>/dev/null; then
        emit deleted local "$(tilde "$path")" "clone of $nwo"
      else
        emit failed local "$(tilde "$path")" "could not remove directory"
        n_failed=$((n_failed + 1))
      fi
    done <"$TMP/paths"
  else
    emit failed remote "$nwo" "$(head -n 1 "$TMP/err")"
    while IFS= read -r path; do
      emit kept local "$(tilde "$path")" "remote delete failed"
    done <"$TMP/paths"
    n_failed=$((n_failed + 1))
  fi
done <"$TMP/forks"

if [ "$DRY_RUN" -eq 1 ]; then
  log "dry run: $n_delete forks would be deleted, $n_kept kept"
else
  log "deleted $n_delete forks, kept $n_kept, failed $n_failed"
fi

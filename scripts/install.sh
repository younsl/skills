#!/usr/bin/env bash
# Usage: scripts/install.sh
set -euo pipefail

root="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
target="$HOME/.claude/skills/houston"

mkdir -p "$(dirname "$target")"
if [[ -e "$target" && ! -L "$target" ]]; then
  echo "error: $target exists and is not a symlink, move it first" >&2
  exit 1
fi
ln -sfn "$root/houston" "$target"
echo "[link] $target -> $root/houston"
echo "Run /reload-plugins in Claude Code to load houston@skills-dir."

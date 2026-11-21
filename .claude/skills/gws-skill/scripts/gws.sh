#!/usr/bin/env bash
# Run gws with credentials from .env. All arguments are passed through unchanged.
# Usage: bash .claude/skills/gws-skill/scripts/gws.sh <service> <command> [flags]
set -uo pipefail
source "$(dirname "${BASH_SOURCE[0]}")/_env.sh"

if ! command -v gws >/dev/null 2>&1; then
  echo "gws not found. Run: bash $(dirname "${BASH_SOURCE[0]}")/check.sh" >&2
  exit 127
fi
exec gws "$@"

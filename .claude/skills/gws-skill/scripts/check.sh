#!/usr/bin/env bash
# Readiness check for gws-skill. Installs gws via npm if missing, checks .env and auth.
# Usage: bash .claude/skills/gws-skill/scripts/check.sh [--no-install]
# Exit: 0 ready | 1 gws/npm missing | 2 .env missing values | 3 not logged in / token invalid
set -uo pipefail
source "$(dirname "${BASH_SOURCE[0]}")/_env.sh"

mask() { local v="$1"; [ ${#v} -le 8 ] && echo "****" || echo "${v:0:8}…(${#v} chars)"; }

echo "[1/3] gws CLI"
if ! command -v gws >/dev/null 2>&1; then
  if [ "${1:-}" = "--no-install" ]; then echo "  ✗ gws not installed"; exit 1; fi
  if ! command -v npm >/dev/null 2>&1; then echo "  ✗ gws and npm not found — install Node.js 18+ first"; exit 1; fi
  echo "  gws not found → npm install -g @googleworkspace/cli"
  npm install -g @googleworkspace/cli >/dev/null 2>&1 || { echo "  ✗ npm install failed"; exit 1; }
  hash -r
fi
echo "  ✓ $(gws --version 2>/dev/null | head -1)"

echo "[2/3] .env"
if [ -z "$GWS_ENV_FILE" ]; then
  echo "  ✗ no .env found. Copy $GWS_SKILL_DIR/.env.example to the project root as .env and fill it in."
  exit 2
fi
echo "  file: $GWS_ENV_FILE"
missing=0
for k in GOOGLE_WORKSPACE_CLI_CLIENT_ID GOOGLE_WORKSPACE_CLI_CLIENT_SECRET; do
  if [ -n "${!k:-}" ]; then echo "  ✓ $k = $(mask "${!k}")"; else echo "  ✗ $k is empty"; missing=1; fi
done
[ -n "${GOOGLE_WORKSPACE_PROJECT_ID:-}" ] && echo "  ✓ GOOGLE_WORKSPACE_PROJECT_ID = $GOOGLE_WORKSPACE_PROJECT_ID"
[ $missing -eq 1 ] && exit 2

echo "[3/3] auth"
status="$(gws auth status 2>/dev/null)"
user="$(echo "$status" | grep -o '"user": *"[^"]*"' | sed 's/.*: *"//;s/"$//')"
valid="$(echo "$status" | grep -o '"token_valid": *[a-z]*' | sed 's/.*: *//')"
scopes="$(echo "$status" | grep -o 'auth/[a-z.]*' | sed 's#auth/##' | grep -vE '^userinfo' | sort -u | tr '\n' ' ')"
if [ "$valid" = "true" ]; then
  echo "  ✓ logged in as $user"
  echo "  scopes: $scopes"
  echo "READY"
  exit 0
fi
echo "  ✗ not logged in or token expired"
echo "  Run (opens a browser for Google sign-in):"
echo "    bash $GWS_SKILL_DIR/scripts/gws.sh auth login -s gmail,drive,docs,sheets,calendar"
exit 3

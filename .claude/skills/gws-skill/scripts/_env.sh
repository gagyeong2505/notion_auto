#!/usr/bin/env bash
# Shared helper: locate .env, export only Google Workspace CLI variables, and put gws on PATH.
# Sourced by gws.sh and check.sh. Sets GWS_ENV_FILE to the file that was loaded (empty if none).

GWS_SKILL_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

# npm global bin on Windows (Git Bash) is not always on PATH.
if [ -n "${APPDATA:-}" ] && command -v cygpath >/dev/null 2>&1; then
  PATH="$PATH:$(cygpath "$APPDATA")/npm"
fi
# gcloud installed per-user (only needed for `gws auth setup`).
if [ -n "${LOCALAPPDATA:-}" ] && command -v cygpath >/dev/null 2>&1; then
  PATH="$PATH:$(cygpath "$LOCALAPPDATA")/Google/google-cloud-sdk/bin"
fi
export PATH

# Search order: $GWS_ENV_FILE > skill dir > parent dirs of the skill (project root) > current dir and its parents.
find_env_file() {
  if [ -n "${GWS_ENV_FILE:-}" ] && [ -f "$GWS_ENV_FILE" ]; then echo "$GWS_ENV_FILE"; return; fi
  local d
  for start in "$GWS_SKILL_DIR" "$PWD"; do
    d="$start"
    while [ -n "$d" ] && [ "$d" != "/" ]; do
      if [ -f "$d/.env" ]; then echo "$d/.env"; return; fi
      d="$(dirname "$d")"
    done
  done
}

load_env_file() {
  local file="$1" line key val
  while IFS= read -r line || [ -n "$line" ]; do
    line="${line%$'\r'}"
    case "$line" in ''|\#*) continue ;; esac
    key="${line%%=*}"; val="${line#*=}"
    key="${key#export }"; key="$(echo "$key" | tr -d '[:space:]')"
    # Only gws-related keys, so other secrets in .env (e.g. NOTION_API_KEY) are not passed to gws.
    case "$key" in GOOGLE_WORKSPACE_*|GWS_*) ;; *) continue ;; esac
    val="${val%\"}"; val="${val#\"}"; val="${val%\'}"; val="${val#\'}"
    [ -n "$val" ] && export "$key=$val"
  done < "$file"
}

GWS_ENV_FILE="$(find_env_file)"
if [ -n "$GWS_ENV_FILE" ]; then load_env_file "$GWS_ENV_FILE"; fi
export GWS_ENV_FILE

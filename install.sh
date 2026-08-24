#!/usr/bin/env bash
# install.sh — one-line installer for the AI workflow kit.
#
# Two ways to use it:
#
#   1. From a local copy (jump drive / clone):
#        bash install.sh
#
#   2. From a machine on the tailnet, as a one-liner (no local copy needed):
#        curl -sL "<your-git-web>/api/v1/repos/gus/ai-workflow-kit/archive/main.tar.gz" \
#          -H "Authorization: token $GITEA_TOKEN" | tar xz -C "$HOME" \
#        && bash "$HOME/ai-workflow-kit/install.sh"
#
# Both end in the same place: the kit installed system-wide via
# setup.sh --global (AGENTS.md + global-scoped skills for this user).
set -euo pipefail

KIT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Prerequisite check: the guardrails need an agent to actually be used.
# Freebuff is the default; other agents (Claude Code, Codex) also work.
if ! command -v freebuff >/dev/null 2>&1; then
  echo "⚠️  Freebuff (the coding agent) is not installed on this machine." >&2
  echo "    Install it first (requires Node.js):" >&2
  echo "        npm install -g freebuff" >&2
  echo "    Or install another agent that reads AGENTS.md / .agents/skills/" >&2
  echo "    (Claude Code, Codex, etc.) — then re-run this script." >&2
  exit 1
fi

echo "✓ Freebuff found: $(command -v freebuff)"

if [ -f "$KIT_DIR/setup.sh" ]; then
  echo "== Installing from local kit at $KIT_DIR =="
  exec "$KIT_DIR/setup.sh" --global
fi

echo "install.sh must be run from inside a kit copy (next to setup.sh)." >&2
echo "Clone or copy the kit first, or use the tailnet one-liner from PORTABILITY.md." >&2
exit 1

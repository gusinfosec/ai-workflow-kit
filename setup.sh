#!/usr/bin/env bash
# setup.sh — bootstrap the AI workflow guardrails.
#
# Usage:
#   ./setup.sh /path/to/target-project   Install into one project (default).
#   ./setup.sh --global                  Install system-wide for this user.
#
# Project mode:
#   1. Copies AGENTS.md into the project root (only if absent).
#   2. Scaffolds SPEC.md / ROADMAP.md / TASKS.md from templates (only if absent).
#   3. Installs the kit's skills into <project>/.agents/skills/ (merge, no overwrite).
#   4. Prints the next steps.
#
# Global mode:
#   1. Installs AGENTS.md to ~/.agents/AGENTS.md (the user-level .agents
#      convention — same layout as project mode, one level up).
#   2. Installs skills to ~/.agents/skills/ (merge, no overwrite).
#   3. If other agents' config dirs exist, also links the guardrails there
#      (Claude Code: ~/.claude/CLAUDE.md, Codex: ~/.codex/AGENTS.md) so every
#      agent on the machine picks the global rules up.
#   4. Prints which agents will now read the rules.
set -euo pipefail

KIT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

copy_if_absent() {
  local src="$1" dst="$2"
  if [ -e "$dst" ]; then
    echo "  - exists, keeping: $dst"
  else
    cp "$src" "$dst"
    echo "  + created: $dst"
  fi
}

# mode: all (project) or global (only skills marked scope: global)
install_skills() {
  local dst="$1" mode="${2:-all}"
  mkdir -p "$dst"
  if [ -d "$KIT_DIR/skills" ]; then
    for skill in "$KIT_DIR/skills"/*/; do
      [ -d "$skill" ] || continue
      local name scope="project"
      name="$(basename "$skill")"
      if [ -f "$skill/SKILL.md" ]; then
        scope=$(sed -n 's/^scope:[[:space:]]*\([^[:space:]]*\).*/\1/p' "$skill/SKILL.md" | head -1)
        [ -z "$scope" ] && scope="project"
      fi
      if [ "$mode" = "global" ] && [ "$scope" != "global" ]; then
        echo "  - skipped (project-scoped): $name"
        continue
      fi
      cp -rn "$skill" "$dst/"
      echo "  + skill: $name ($scope)"
    done
  fi
}

if [ "${1:-}" = "--global" ]; then
  echo "== Install system-wide for user $(whoami) =="

  AGENTS_HOME="$HOME/.agents"
  mkdir -p "$AGENTS_HOME"

  # 1. Global guardrails
  copy_if_absent "$KIT_DIR/AGENTS.md" "$AGENTS_HOME/AGENTS.md"

  # 2. Global skills — only scope: global ones travel system-wide
  install_skills "$AGENTS_HOME/skills" global

  # 3. Mirror into other agents' config dirs when they exist
  if [ -d "$HOME/.claude" ]; then
    copy_if_absent "$KIT_DIR/AGENTS.md" "$HOME/.claude/CLAUDE.md"
  fi
  if [ -d "$HOME/.codex" ]; then
    copy_if_absent "$KIT_DIR/AGENTS.md" "$HOME/.codex/AGENTS.md"
  fi

  echo
  echo "== Installed =="
  echo "  ~/.agents/AGENTS.md        global guardrails (any agent using .agents)"
  echo "  ~/.agents/skills/          global skills, loadable by name in any session"
  [ -d "$HOME/.claude" ] && echo "  ~/.claude/CLAUDE.md         Claude Code global memory"
  [ -d "$HOME/.codex" ]  && echo "  ~/.codex/AGENTS.md          Codex global instructions"
  echo
  echo "Project AGENTS.md files still layer ON TOP of these — project specifics"
  echo "win, global behavior rules always apply."
  exit 0
fi

if [ $# -ne 1 ]; then
  echo "Usage: $0 /path/to/target-project   (or)   $0 --global" >&2
  exit 1
fi

TARGET="${1%/}"
if [ ! -d "$TARGET" ]; then
  echo "Error: target directory does not exist: $TARGET" >&2
  exit 1
fi

PROJECT_NAME="$(basename "$TARGET")"
TODAY="$(date +%Y-%m-%d)"

echo "== Bootstrap '$PROJECT_NAME' =="

# 1. Global guardrails
copy_if_absent "$KIT_DIR/AGENTS.md" "$TARGET/AGENTS.md"

# 2. Spec / roadmap / tasks from templates
copy_if_absent "$KIT_DIR/templates/SPEC.md.tmpl"   "$TARGET/SPEC.md"
copy_if_absent "$KIT_DIR/templates/ROADMAP.md.tmpl" "$TARGET/ROADMAP.md"
copy_if_absent "$KIT_DIR/templates/TASKS.md.tmpl"   "$TARGET/TASKS.md"

# 3. Skills -> .agents/skills/
install_skills "$TARGET/.agents/skills"

# 4. Fill template placeholders with project context
sed -i "s/{{PROJECT_NAME}}/$PROJECT_NAME/g; s/{{DATE}}/$TODAY/g" \
  "$TARGET/SPEC.md" "$TARGET/ROADMAP.md" "$TARGET/TASKS.md" 2>/dev/null || true

echo
echo "== Next steps =="
echo "  1. Open $TARGET/SPEC.md and fill in the problem, versions, and acceptance criteria."
echo "  2. Edit ROADMAP.md to define phase 1 and its exit criteria."
echo "  3. Open Freebuff in $TARGET and start with:"
echo "     \"Read AGENTS.md and SPEC.md, then propose the first phase of ROADMAP.md.\""
echo
echo "  Tip: run '$0 --global' to also install the guardrails system-wide."

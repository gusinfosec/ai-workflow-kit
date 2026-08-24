---
name: bash-validation
scope: global
description: How to safely validate shell/bash scripts in this workspace before running or committing them. Use when writing, editing, or reviewing .sh scripts.
---

# Bash Validation

Shell scripts are easy to get wrong in ways that only show up at runtime.
This skill captures the validation that must run before a bash change is
considered done.

## When to use

- Writing or editing any `.sh` file.
- Reviewing a change that touches a shell script.
- Copying a script between machines / into a new project.

## Validation checklist

Run these in order. All must pass before the change is done.

1. **Syntax check**
   ```bash
   bash -n script.sh
   ```
2. **Shellcheck** (if installed — catches real bugs, not style nits)
   ```bash
   shellcheck script.sh
   ```
3. **Diff hygiene**
   ```bash
   git diff --check
   ```
4. **Dry-run / safe first execution** — never run a new script against
   production, remote hosts, or anything with side effects without showing the
   user the exact command first.

## Environment-specific rules

- Scripts must be POSIX-bash compatible; no zsh-only syntax.
- Use `set -euo pipefail` unless the script explicitly needs otherwise.
- Never hard-code absolute paths to another machine's home directory —
  use `$HOME` or relative paths so the script stays portable.
- When a script is meant to run over SSH, prefer a heredoc with quoted
  delimiter (`ssh host 'bash -s' <<'EOF'`) so remote variables are not
  expanded locally.

## Verification

If the project has a test that exercises the script, run it. If not, verify the
script's effect in a scratch copy (e.g., `cp -r` the affected files to /tmp)
before touching the real ones.

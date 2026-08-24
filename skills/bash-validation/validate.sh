#!/usr/bin/env bash
# validate.sh — run the bash-validation skill checklist on one or more scripts.
# Usage: ./validate.sh path/to/script.sh [more...]
set -uo pipefail

fail=0

for f in "$@"; do
  echo "== $f =="
  if [ ! -f "$f" ]; then
    echo "  ✗ not a file"; fail=1; continue
  fi
  if bash -n "$f"; then echo "  ✓ syntax (bash -n)"; else fail=1; fi
  if command -v shellcheck >/dev/null 2>&1; then
    if shellcheck "$f"; then echo "  ✓ shellcheck"; else fail=1; fi
  else
    echo "  - shellcheck not installed (skipped)"
  fi
done

echo
if [ "$fail" -eq 0 ]; then
  echo "All checks passed."
else
  echo "One or more checks FAILED."
  exit 1
fi

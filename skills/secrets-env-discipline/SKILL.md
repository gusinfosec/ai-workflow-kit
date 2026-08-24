---
name: secrets-env-discipline
scope: global
description: Rules for handling API keys, tokens, and .env files — never commit secrets, keep them out of logs/chat, and rotate any key that has been shared.
---

# Secrets & .env Discipline

Live keys have been shared in chat and stored in docs. These rules keep that
from becoming a breach.

## Hard rules

1. **Never commit secrets.** `.env`, `*.pem`, `*.key`, `*token*` belong in
   `.gitignore`. Before any commit, check `git status` for stray env files.
2. **Never print full secret values** in command output, logs, or file
   dumps. Mask them: `grep KEY .env | sed 's/=.\{6\}.*/=<set>/'`.
3. **Keys live in one place**: `~/projects/cgt-operations/docs/<your-keys-doc>.md`
   (plus each app's `.env` on the host). Do not duplicate them into new docs
   or code.
4. **Rotate after sharing.** If a live key ever appears in chat, a doc, or a
   paste, it must be rotated and the doc updated. Assume exposure.
5. **Live vs test keys.** `sk_live_` / `pk_live_` are production — never use
   them in tests or throwaway scripts. Keep `sk_test_` for staging.

## Reading keys from the key doc safely

The <your-keys-doc> doc has label / blank line / value formatting. Extract without
printing:

```bash
TOKEN=$(awk '/^Gitea/{getline; getline; print; exit}' <your-keys-doc>.md | tr -d ' \r\n')
# verify length only, never the value
echo "token len: ${#TOKEN}"
```

## Environment checks

- `grep -oE '^[A-Z_]+' .env | sort` — list variable NAMES only, never values.
- Before deploying: confirm required env vars exist on the target host
  (`grep -E 'KEY|TOKEN|SECRET' .env | sed 's/=.\{6\}.*/=<set>/'`).

## If a secret leaks

1. Rotate it at the provider immediately.
2. Update the key doc + the app's `.env`.
3. Redeploy anything that cached the old value.
4. Note the rotation in the session log so it is tracked.

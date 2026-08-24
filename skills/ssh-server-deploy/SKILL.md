---
name: ssh-server-deploy
scope: project
description: Safe deploy pattern for apps hosted on <your-server> — rsync only source, rebuild with docker compose, then curl-verify the service actually serves the new code.
---

# SSH / Deploy to <Your-Server>

<Your-Server> hosts the containerized apps (vendorsafe, reportsafe, propaudit,
etc.). This is the proven deploy loop.

## The loop

```bash
# 1. Sync ONLY source (never node_modules, .next, dist, .git, .env)
rsync -az --exclude node_modules --exclude .next --exclude dist \
  --exclude .git --exclude .env web/src <your-server>:~/projects/<app>/web/
rsync -az --exclude node_modules --exclude dist --exclude .git \
  --exclude .env api/src <your-server>:~/projects/<app>/api/

# 2. Rebuild + restart
ssh <your-server> 'cd ~/projects/<app> && docker compose up -d --build 2>&1 | tail -4'

# 3. Verify it serves the NEW code
sleep 5
ssh <your-server> 'curl -s -m 10 -o /dev/null -w "%{http_code}\n" http://127.0.0.1:<port>/'
```

## Rules

- **Exclude build artifacts and secrets** in every rsync (see above). Syncing
  `.env` from the laptop can overwrite host secrets — never do it.
- Always curl-verify after a deploy. A successful build is not proof the app
  serves the new version.
- Use `ssh -o ConnectTimeout=8` and wrap with `timeout 30-60` so a hanging
  connection cannot stall the session.
- Quote remote commands in single quotes; use a `bash -s <<'EOF'` heredoc for
  multi-line remote scripts (quoted delimiter = no local expansion).
- For multi-file syncs, prefer rsync over scp (idempotent, excludes work).

## Troubleshooting a "nothing changed" report

1. Is the app container actually running? `docker ps --filter name=<app>`
2. Does the served bundle contain the new marker?
   `curl -s <url>/app.js | grep -c '<newMarker>'`
3. Was the deploy pointed at the right branch/format? (wrangler preview-vs-
   production trap, stale build cache, etc.)
4. Browser cache — hard refresh (Ctrl+Shift+R) before assuming the deploy
   failed.

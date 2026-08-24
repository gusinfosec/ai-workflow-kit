---
name: deploy-safely
scope: global
description: Safe deploy loop for any hosted app — sync only source (never build artifacts or secrets), rebuild, then verify the service actually serves the new code before calling it done.
---

# Deploy Safely

The proven deploy pattern for containerized apps: **sync only source → rebuild → verify**. A successful build is not proof the app serves the new version.

## The loop

```bash
# 1. Sync ONLY source (never node_modules, .next, dist, .git, .env)
rsync -az --exclude node_modules --exclude .next --exclude dist \
  --exclude .git --exclude .env web/src <host>:<path>/web/
rsync -az --exclude node_modules --exclude dist --exclude .git \
  --exclude .env api/src <host>:<path>/api/

# 2. Rebuild + restart
ssh <host> 'cd <path> && docker compose up -d --build 2>&1 | tail -4'

# 3. Verify it serves the NEW code
sleep 5
ssh <host> 'curl -s -m 10 -o /dev/null -w "%{http_code}\n" http://127.0.0.1:<port>/'
```

## Rules

- **Exclude build artifacts and secrets in every rsync.** Syncing `.env`
  from a laptop can overwrite host secrets — never do it.
- **Always verify after a deploy.** Curl the service (or hit a health
  endpoint) and confirm it responds before reporting success.
- Use `ssh -o ConnectTimeout=8` and wrap long operations with `timeout 30-60`
  so a hanging command can't stall the session.
- When the deploy touches a database or has irreversible effects, stop and
  ask before running it.
- One deploy at a time; confirm each service is healthy before moving to the
  next.

## When to use

Any time you push code to a running service: a landing page, an API, a
dashboard, or a scheduled job. If you deploy and skip verification, you
haven't finished the task.

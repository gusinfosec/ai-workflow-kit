---
name: cloudflare-pages-wrangler
scope: project
description: How to deploy the Cloudflare Pages dashboard (and similar direct-upload projects) to PRODUCTION with wrangler, including the preview-vs-production trap and post-deploy verification.
---

# Cloudflare Pages (Wrangler) Deployment

The CGT Analytics dashboard is a **Cloudflare Pages direct-upload project** —
git pushes to GitHub do NOT deploy it. It must be deployed manually with
wrangler. Getting this wrong silently serves the old version to users.

## The #1 trap: preview vs production branch

- `--branch=main` (or any non-`production` branch) creates a **preview**
  deployment. The custom domain keeps serving the OLD build.
- Only `--branch=production` updates what the custom domain serves.

Always deploy with `--branch=production`.

## Deploy to production

Stage ONLY the files that belong in the site (never `.git`, `.wrangler`,
`docs`, or source folders):

```bash
cd ~/projects/<your-pages-project>
rm -rf /tmp/dash-prod && mkdir -p /tmp/dash-prod/functions/api
cp index.html 404.html favicon* apple-touch-icon.png /tmp/dash-prod/ 2>/dev/null
cp functions/api/events.js functions/api/bookmarks.js /tmp/dash-prod/functions/api/

cd /tmp/dash-prod
npx wrangler pages deploy . \
  --project-name=<your-pages-project> \
  --branch=production \
  --commit-dirty=true
```

## Verify the deployment actually went to production

```bash
npx wrangler pages deployment list --project-name=<your-pages-project>
# The newest row must say Production, not Preview.
```

Then check the deployment alias (the hash URL from the list) for the new
markers — the custom domain is behind Cloudflare Access, so curl it via the
alias instead:

```bash
curl -s -m 20 'https://<hash>.<your-pages-project>.pages.dev/' -o /tmp/dash-verify.html
grep -c 'NewPanelHeading' /tmp/dash-verify.html   # must be > 0
```

## Other rules

- Use `npx wrangler` from the project (local install preferred).
- The production URL returns 302 → login (Cloudflare Access) — that is
  expected, not a failure.
- After deploying, hard-refresh (Ctrl+Shift+R) in an authenticated browser
  to confirm visually.
- If the user says "I don't see changes", first suspect preview-branch deploy
  or stale cache, not the code.

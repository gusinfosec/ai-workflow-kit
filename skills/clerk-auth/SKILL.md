---
name: clerk-auth
scope: global
description: Clerk authentication conventions — separate key pairs and webhooks per app, tier gating on user metadata, and middleware protection patterns.
---

# Clerk Auth

## One Clerk instance per app

- Each app (vendorsafe, reportsafe, etc.) has its OWN Clerk keys:
  `NEXT_PUBLIC_CLERK_PUBLISHABLE_KEY` (`pk_live_...`) and
  `CLERK_SECRET_KEY` (`sk_live_...`). Never mix keys between apps.
- The user creates separate Clerk logins per app to avoid confusion — do not
  "reuse" an app's Clerk for another app.

## Webhooks

- Each app has its own Clerk webhook route
  (`web/src/app/api/webhooks/clerk/route.ts`) with its own
  `CLERK_WEBHOOK_SECRET` (`whsec_...`).
- The webhook syncs user creation/update events into the app (e.g. storing
  the user + their tier).
- If the user asks "why does only X have a webhook?" — each app that needs
  user provisioning must have its own; others may not need it.

## Tier gating

- Free vs paid tiers are enforced on the server side using the user's
  metadata/tier from Clerk (set at signup or by the billing webhook).
- The analyze/paid routes must check the tier server-side — never rely only
  on hiding buttons in the UI.
- If a user without a paid tier can reach a paid page, that is a gating bug.

## Middleware

- `middleware.ts` protects routes (`/analyze`, etc.) — signed-out users
  redirect to sign-in.
- After adding Clerk to a page, verify the sign-in wall actually appears
  (a wired backend with a missing page guard is the common failure).

## Verification

- Sign in → protected page loads.
- Sign out → protected page redirects.
- New user appears in the app's user table via the webhook.
- Tier upgrades/downgrades reflect on the next request.

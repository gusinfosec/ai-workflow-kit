---
name: stripe-billing
scope: global
description: Stripe billing conventions across the apps — price IDs in env, monthly/annual pairs, per-app webhook secrets, and live-vs-test discipline.
---

# Stripe Billing

## Price IDs live in env, not code

- Price IDs are `STRIPE_PRICE_*` env vars, with `_ANNUAL` variants where
  annual billing exists (e.g. `STRIPE_PRICE_PRO`, `STRIPE_PRICE_PRO_ANNUAL`).
- The checkout route maps tier → price ID via an env accessor; monthly is the
  default interval, `interval=year` selects the annual price.
- Metadata on checkout: `tier` + `interval` so the webhook knows what was
  bought.

## Webhooks

- Each app gets its OWN webhook endpoint + secret (`whsec_...`) — never share
  a webhook secret between apps.
- The webhook endpoint must be created for that app's domain. If the user
  created one for the wrong app, that is a bug to fix, not to work around.
- When a webhook secret is added/changed, update the app env and redeploy.

## Live vs test keys

- `sk_live_` / `pk_live_` = production. Never paste them into test scripts.
- The user operates in production only ("no test mode") — verify against live
  keys but never print full values (mask with `sed 's/=.\{6\}.*/=<set>/'`).

## Plan/tier changes

- If prices/tiers change on the site, the matching Stripe products/prices
  must be updated too — keep both in sync.
- Products should have an icon/logo in Stripe where the user asks for it.
- Document every tier in the app's pricing page so the offers are visible to
  customers.

## Verification

- Checkout creates a session with the right price ID + metadata.
- Webhook receives the event and grants the tier.
- Annual price selected when the toggle is on annual.

---
name: nextjs-validation
scope: global
description: Required validation gates for Next.js apps in this workspace (compliance-ai, propaudit, reportsafe) before declaring a change done — typecheck, lint, build.
---

# Next.js Validation

These apps are Next.js with strict TypeScript. The gates below catch the
failures we have hit (e.g. implicit-any callbacks breaking the Render build).

## Always run (in the app's `web/` directory)

```bash
./node_modules/.bin/tsc --noEmit        # typecheck (strict mode is ON)
# project linter if configured (check package.json scripts)
# production build:
npm run build  # or pnpm/yarn — use whatever the project uses
```

- Use the project's local binaries (`./node_modules/.bin/...`), not global.
- `strict: true` is committed in the tsconfig — do not relax it to make
  errors go away. Fix the types (annotate callbacks, narrow types).
- A green typecheck on a stale commit proves nothing — rerun on the LATEST
  state after any fix.

## Common strict-mode gotchas

- `.filter()` / `.map()` callbacks with implicit `any` params — annotate them
  (`(row: [string, string]) => ...`).
- Optional chaining on possibly-undefined state.
- Unused imports/vars failing `noUnusedLocals`.

## Deploy specifics

- Render builds run the typecheck as part of the build. If Render fails,
  first reproduce locally with `tsc --noEmit`.
- Env vars: `web/.env*` names must match `lib/env.ts` accessors exactly.
  Adding a new accessor without the env var set breaks the build — keep a
  safe default or fail fast with a clear message.

## Verification

- After changes, run typecheck AND build; both must pass.
- If the app renders server-side, verify the changed page in the browser
  (or via curl for a status code) after deploy.

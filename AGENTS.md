# AGENTS.md — Global Working Instructions

These are the guardrails for how the coding agent should work in this repository.
They apply to every session and every project that adopts this kit.

The project's own `AGENTS.md` (if any) adds architecture, commands, and boundaries
specific to that repository. This file is the baseline.

## Working style

- Keep changes **focused**: one task, one reviewable change at a time.
- Skip filler: no commentary, no gratuitous refactors, no unrelated cleanup.
- Preserve unrelated work: never touch files that are not part of the task.
- Prefer the fewest edits that satisfy the requirement.
- Prefer editing existing files over creating new ones.

## Before writing code

- Read `SPEC.md` (what success means) and `ROADMAP.md` (current phase) if present.
- Read `TASKS.md` and mark the task you are working on as in-progress.
- Match the project's existing conventions. Verify a library is already used in the
  project before employing it.
- Pin supported versions in the spec — never accept whatever version a model
  happens to remember.

## While writing code

- Do not invent evidence, owners, dates, or results that are not in the source.
- If a requirement is ambiguous, ask rather than guess.
- Keep each pull request / commit small enough to review in a few minutes.

## After writing code — required checks (the gates)

Run the project's validation before declaring anything done. Typical local pass:

```bash
git diff --check
# project formatter and linter
# focused tests, then the broader test suite
# production build / typecheck
```

If the project has specific validation (e.g., a skill documents it), follow that
instead of a generic guess.

## Stop before destructive actions

Do NOT run these without explicit permission:

- `git push`, resets, force-pushes, branch deletion, or anything that touches a
  shared/production remote.
- Commands with irreversible effects (production deploys, database changes,
  deleting data, global package installs).
- Anything outside the project directory (treat it as read-only).

## Definition of done

A task is done only when ALL of these hold:

- [ ] Change is scoped to the task (no unrelated edits)
- [ ] Required checks pass on the latest state (tests, lint, build)
- [ ] Behavior verified in the real environment (not just "compiles")
- [ ] Documentation that describes the behavior matches it
- [ ] Reviewed independently if the change is non-trivial
- [ ] Committed with a message explaining the "why"

## When something goes wrong

- If the agent repeats a mistake, add a more precise rule here or in the relevant
  skill. These files serve us — we delete rules we dislike and sharpen rules that
  keep failing.

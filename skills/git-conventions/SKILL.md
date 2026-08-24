---
name: git-conventions
scope: global
description: Git house style for this workspace — scoped commit messages with the why, the Codebuff footer, ask-before-push, and small reviewable changes.
---

# Git Conventions

## Commit style

- Scoped, imperative subjects: `feat:`, `fix:`, `docs:`, `chore:`.
- Message explains the WHY, not just the what.
- End commits with the Codebuff footer:

```
🤖 Generated with Codebuff
Co-Authored-By: Codebuff <noreply@codebuff.com>
```

Use a heredoc so the multi-line message works on any OS:

```bash
git commit -m "$(cat <<'EOF'
feat: add X

Why this change...

🤖 Generated with Codebuff
Co-Authored-By: Codebuff <noreply@codebuff.com>
EOF
)"
```

## Before committing

- `git status --short` + `git diff` — review staged and unstaged changes.
- `git diff --check` — no whitespace errors.
- Only stage files relevant to the change (`git add <paths>` or `-am` when
  safe) — never `git add -A` into a repo with unrelated untracked files.
- Never commit secrets, `.env`, or generated artifacts.

## Ask before push — always

- `git push` can break production. NEVER push without explicit permission,
  even to a private repo, unless the user asked for it.
- Same for `git reset`, force-push, branch deletion, rebase.
- After push to Gitea, verify: `git log --oneline origin/main -1`.

## Small changes

- One task = one commit = one reviewable diff.
- If a review takes 20 minutes because the diff is enormous, split it.
- Preserve unrelated work: never commit files that are not part of the task.

## Remotes

- Primary private home: Gitea `<your-git-remote>/gus/<repo>.git`
- Some repos also mirror to GitHub (Render / Pages auto-deploy) — know which
  remote triggers a deploy before pushing.

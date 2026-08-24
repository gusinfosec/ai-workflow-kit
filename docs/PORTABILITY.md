# PORTABILITY — Moving the Kit to Another Computer

The kit is plain-text files + skills. These are the four ways to get it onto a
new machine and install it system-wide. Copy-paste friendly.

## Step 0 — Install the agent (Freebuff) first

The kit is the guardrails — it needs a coding agent to actually be used.
Install Freebuff once per machine (requires Node.js):

```bash
npm install -g freebuff
```

Verify: `freebuff --version`. Other agents that read AGENTS.md /
`.agents/skills/` (Claude Code, Codex) also work — `install.sh` will tell you
if no agent is present.

## Option A — Jump drive (simplest, works offline)

On this machine:

```bash
cp ~/projects/ai-workflow-kit.tar.gz /media/<your-usb>/
```

On the other computer:

```bash
tar xzf /media/<your-usb>/ai-workflow-kit.tar.gz -C "$HOME"
bash ~/ai-workflow-kit/install.sh
```

## Option B — Clone from Gitea (tailnet / LAN)

Any machine on the tailnet (or same LAN as the homelab):

```bash
git clone <your-git-remote>/gus/ai-workflow-kit.git ~/ai-workflow-kit
bash ~/ai-workflow-kit/install.sh
```

Needs an SSH key registered for that machine (same as cloning vendorsafe,
reportsafe, etc.). Bonus: `git -C ~/ai-workflow-kit pull` gets updates.

## Option C — Clone from GitHub (anywhere)

Requires GitHub auth (gh CLI logged in, or SSH key):

```bash
git clone git@github.com:<your-github-username>/ai-workflow-kit.git ~/ai-workflow-kit
bash ~/ai-workflow-kit/install.sh
```

Repo is private: `<your-github-username>/ai-workflow-kit`.

## Option D — One-line installer (tailnet, no clone)

From any machine on the tailnet, with the Gitea token in your shell:

```bash
export GITEA_TOKEN=<token-from-<your-keys-doc>.md>
curl -sL "<your-git-web>/api/v1/repos/gus/ai-workflow-kit/archive/main.tar.gz" \
  -H "Authorization: token $GITEA_TOKEN" | tar xz -C "$HOME"
bash "$HOME/ai-workflow-kit/install.sh"
```

The token is only used in the request header, never in the URL or logs.

## After any option — what you get

`install.sh` checks for the agent, then runs `setup.sh --global`, which installs:

- `~/.agents/AGENTS.md` — global guardrails
- `~/.agents/skills/` — only **scope: global** skills (bash-validation,
  secrets-env-discipline, git-conventions, nextjs-validation,
  node-express-api, stripe-billing, clerk-auth)
- Mirrors to `~/.claude/CLAUDE.md` and `~/.codex/AGENTS.md` when present

Project-scoped skills (wrangler, <your-server> docker/ssh, PIL assets) install
per-project with `setup.sh <dir>` — they only belong on machines that use them.

## Updating an existing install

```bash
git -C ~/ai-workflow-kit pull   # refresh the kit
bash ~/ai-workflow-kit/install.sh   # re-apply (never overwrites)
```

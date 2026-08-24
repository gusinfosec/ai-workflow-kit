---
name: docker-compose-ops
scope: project
description: Safe Docker Compose operations on the <your-server> homelab server — validate before restarting, recover stale bind-mounts, and back up configs before editing.
---

# Docker Compose on <Your-Server>

<Your-Server> hosts the homelab containers (Glance, Jellyfin, apps, cloudflared).
These rules prevent the failures we have actually hit.

## Validate before you restart

```bash
docker compose config          # parses + validates the compose file
docker ps --filter name=<name> # state before touching anything
```

## The stale bind-mount trap (Jellyfin / removable drives)

When a drive that is bind-mounted into a container is unplugged and later
reconnected (e.g. `/DATA/HDD3` USB enclosure), the **running container keeps a
stale mount** and throws `Input/output error` even after the drive is back.
The one-liner fix:

```bash
docker restart jellyfin
```

The host mount itself auto-recovers via fstab automount — only the container
needs the restart.

## Never bind-mount removable drives into critical containers

Glance crashed on every restart because its compose mounted `/DATA/HDD3`,
which can be unplugged. Rule: containers that must survive drive swaps
(Glance) do NOT mount removable drives. Jellyfin may, but accepts the
restart-recovery pattern above.

## Back up configs before editing

Copy the file first, with a timestamp:

```bash
cp glance.yml glance.yml.bak-$(date +%Y%m%d-%H%M%S)
cp docker-compose.yml docker-compose.yml.bak-$(date +%Y%m%d-%H%M%S)
```

## Diagnosing a stopped container

`docker logs` can hang over SSH — use `docker inspect` instead:

```bash
docker inspect <container> --format '{{.State.Status}} | exit={{.State.ExitCode}} | oom={{.State.OOMKilled}}'
docker inspect <container> --format '{{json .Mounts}}'
```

## Recreate after compose edits

```bash
cd <compose dir> && docker compose up -d --build
sleep 5
docker ps --filter name=<name> --format '{{.Names}} | {{.Status}}'
```

## SSH hygiene

- Always use timeouts: `timeout 30 ssh -o ConnectTimeout=8 <your-server> '...'`
- Quote remote commands in single quotes so local shell does not expand them.

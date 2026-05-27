# OpenCode Web

Dockerized environment running [OpenCode](https://opencode.ai) with its built-in web interface for interacting with OpenCode agents directly from a browser.

## What it does

This project provides a self-hosted web UI for OpenCode. It lets you:

- Access OpenCode agents through a browser or mobile device
- Work on multiple git repositories mounted into the container
- Configure OpenCode with custom agents, commands, and rules
- Run OpenCode sessions on a remote server or local machine without installing anything besides Docker

The stack inside the container:
- **OpenCode CLI and web UI** — the AI coding assistant and browser interface
- **Node 20** — runtime

## How to run

```bash
docker compose up -d
```

Then open `http://localhost:3000` in your browser.

To run on a different port, set `OPENCODE_PORT` in `.env` and restart the container:

```env
OPENCODE_PORT=4096
```

Then open `http://localhost:4096`.

The container uses host networking, so the OpenCode process binds directly to `OPENCODE_PORT`; there is no separate Docker port mapping to update.

To protect the UI, set `OPENCODE_SERVER_PASSWORD` in `.env`. The default username is `opencode`.

## How to update

Rebuild the image to pull the latest version of OpenCode:

```bash
docker compose build --no-cache
docker compose up -d
```

## Managing repositories

Edit `docker-compose.yml` to mount the repositories you want OpenCode to access.

The `repositories` volume maps `./repositories` on your host to `/home/repositories` inside the container:

```yaml
volumes:
  - "./repositories:/home/repositories"
```

Clone or copy your git repos into `./repositories/` on your host machine. Each subdirectory becomes a project OpenCode can work on inside the container.

**Important:** `repositories/` is in `.gitignore` — it won't be committed to this repo.

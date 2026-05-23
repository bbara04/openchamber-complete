# OpenCode Web

Dockerized environment running [OpenCode CLI](https://opencode.ai) and [OpenChamber](https://github.com/openchamber/openchamber) — a web-based interface (including PWA) for interacting with OpenCode agents directly from a browser.

## What it does

This project provides a self-hosted web UI for OpenCode. It lets you:

- Access OpenCode agents through a browser or mobile device
- Work on multiple git repositories mounted into the container
- Configure OpenCode with custom agents, commands, and rules
- Run OpenCode sessions on a remote server or local machine without installing anything besides Docker

The stack inside the container:
- **OpenCode CLI** — the AI coding assistant
- **OpenChamber** — web frontend that exposes OpenCode via a browser UI
- **Node 20** — runtime

## How to run

```bash
docker compose up -d
```

Then open `http://localhost:3000` in your browser. The UI is protected by a password — see `UI_PASSWORD` in `docker-compose.yml`.

Default password: `Titok123` (change it by editing `UI_PASSWORD` in `docker-compose.yml`)

## How to update

Rebuild the image to pull the latest versions of OpenCode and OpenChamber:

```bash
docker compose build --no-cache
docker compose up -d
```

## Browser and PWA notifications

OpenChamber notifications are enabled in `openchamber-config/settings.json` for:

- Prompt completion: `notifyOnCompletion`
- Questions/input needed: `notifyOnQuestion`
- Errors: `notifyOnError`
- Subtasks: `notifyOnSubtasks`

To receive notifications, open OpenChamber in your browser or installed PWA and allow notifications for the site/app when prompted. If notifications were previously blocked, reset the site notification permission in your browser settings.

For mobile/PWA notifications, install OpenChamber as a PWA and prefer an HTTPS URL, such as a tunnel or reverse proxy, because background notifications are limited on plain HTTP.

## Managing repositories

Edit `docker-compose.yml` to mount the repositories you want OpenCode to access.

The `repositories` volume maps `./repositories` on your host to `/root/repositories` inside the container:

```yaml
volumes:
  - "./repositories:/root/repositories"
```

Clone or copy your git repos into `./repositories/` on your host machine. Each subdirectory becomes a project OpenCode can work on inside the container.

**Important:** `repositories/` is in `.gitignore` — it won't be committed to this repo.

# OpenCode Web

Dockerized [OpenCode](https://opencode.ai) with [OpenChamber](https://github.com/openchamber/openchamber) as the browser/PWA frontend.

## What it does

This project runs OpenChamber in the container and lets OpenChamber start and keep OpenCode available in the background.

The stack inside the container:

- **OpenCode CLI** — the AI coding assistant
- **OpenChamber** — web frontend that starts and presents OpenCode
- **Node 20** — runtime

## How to run

```bash
docker compose up -d
```

Open `http://localhost:5200` in your browser.

To run OpenChamber on a different port, set `OPENCHAMBER_PORT` in `.env` and restart the container:

```env
OPENCHAMBER_PORT=5300
```

The container uses host networking, so OpenChamber binds directly to `OPENCHAMBER_PORT`; there is no separate Docker port mapping to update.

To protect the UI, set `UI_PASSWORD` in `.env`.

## How to update

Rebuild the image to pull the latest versions of OpenCode and OpenChamber:

```bash
docker compose build --no-cache
docker compose up -d
```

## Managing repositories

Set `REPOSITORIES_PATH` in `.env` to the host directory that contains repositories OpenCode should work on:

```env
REPOSITORIES_PATH=./repositories
```

The directory is mounted at `/home/repositories` inside the container.

## Browser and PWA notifications

OpenChamber can send browser notifications for prompt completion, questions, errors, and subtasks.

To receive notifications, open OpenChamber in your browser or installed PWA and allow notifications for the site/app when prompted. If notifications were previously blocked, reset the site notification permission in your browser settings.

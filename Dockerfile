FROM node:20-alpine

RUN apk add --no-cache curl bash ca-certificates git openssh tar docker-cli docker-cli-compose

ENV HOME=/home

# Install OpenCode CLI
RUN curl -fsSL https://opencode.ai/install | bash

# Install OpenChamber (web + PWA)
RUN curl -fsSL https://raw.githubusercontent.com/openchamber/openchamber/main/scripts/install.sh | bash

ENV OPENCODE_BINARY="/home/.opencode/bin/opencode"
ENV OPENCHAMBER_HOST="0.0.0.0"

WORKDIR /home

EXPOSE 5200

CMD ["sh", "-c", "rm -f /home/.config/openchamber/run/openchamber-*.pid /home/.config/openchamber/run/openchamber-*.json && exec openchamber serve --host 0.0.0.0 --port 5200 --foreground ${UI_PASSWORD:+--ui-password $UI_PASSWORD}"]

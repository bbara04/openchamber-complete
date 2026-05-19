FROM node:20-alpine

RUN apk add --no-cache curl bash ca-certificates git openssh tar

ENV HOME=/home/agent

# Create non-root user
RUN addgroup -S agent && adduser -S agent -G agent -h /home/agent

# Pre-create .config with correct ownership so install scripts don't create it as root
RUN mkdir -p /home/agent/.config && chown -R agent:agent /home/agent/.config

# Install OpenCode CLI
RUN curl -fsSL https://opencode.ai/install | bash

# Install OpenChamber (web + PWA)
RUN curl -fsSL https://raw.githubusercontent.com/openchamber/openchamber/main/scripts/install.sh | bash

ENV OPENCODE_BINARY="/home/agent/.opencode/bin/opencode"
ENV OPENCHAMBER_HOST="0.0.0.0"

# Re-fix ownership after installs
RUN chown -R agent:agent /home/agent

WORKDIR /home/agent

USER agent

EXPOSE 3000

CMD ["sh", "-c", "openchamber serve --host 0.0.0.0 --port 3000 --foreground ${UI_PASSWORD:+--ui-password $UI_PASSWORD}"]

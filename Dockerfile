FROM node:20-alpine

RUN apk add --no-cache curl bash ca-certificates git openssh tar

# Install OpenCode CLI
RUN curl -fsSL https://opencode.ai/install | bash

# Install OpenChamber (web + PWA)
RUN curl -fsSL https://raw.githubusercontent.com/openchamber/openchamber/main/scripts/install.sh | bash

COPY workflow/agents /root/.config/opencode/agent
COPY workflow/commands /root/.config/opencode/command
COPY workflow/skills /root/.config/opencode/skill
COPY workflow/plugins /root/.config/opencode/plugin

ENV OPENCODE_BINARY="/root/.opencode/bin/opencode"
ENV OPENCHAMBER_HOST="0.0.0.0"

EXPOSE 3000

CMD ["sh", "-c", "openchamber serve --host 0.0.0.0 --port 3000 --foreground ${UI_PASSWORD:+--ui-password $UI_PASSWORD}"]

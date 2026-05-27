FROM node:20-bookworm-slim

RUN apt-get update \
    && apt-get install -y --no-install-recommends \
        curl \
        bash \
        ca-certificates \
        coreutils \
        findutils \
        git \
        grep \
        openssh-client \
        tar \
        docker.io \
        docker-compose \
        python3 \
        make \
        g++ \
    && rm -rf /var/lib/apt/lists/*

ENV HOME=/home

# Install OpenCode CLI
RUN curl -fsSL https://opencode.ai/install | bash

ENV PATH="/home/.opencode/bin:${PATH}"
ENV OPENCODE_PORT="3000"

WORKDIR /home

CMD ["sh", "-c", "exec opencode web --hostname 0.0.0.0 --port ${OPENCODE_PORT:-3000}"]

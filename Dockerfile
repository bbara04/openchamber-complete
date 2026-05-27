FROM node:20-bookworm-slim

ARG UID=1000
ARG GID=1000

RUN apt-get update \
    && apt-get install -y --no-install-recommends \
        bash \
        ca-certificates \
        coreutils \
        curl \
        findutils \
        git \
        g++ \
        jq \
        make \
        openssh-client \
        procps \
        python3 \
        python3-pip \
        ripgrep \
        tar \
        zsh \
        docker.io \
        docker-compose \
    && rm -rf /var/lib/apt/lists/*

ENV HOME=/home

# Install OpenCode CLI
RUN curl -fsSL https://opencode.ai/install | bash

ENV PATH="/home/.opencode/bin:${PATH}"
ENV OPENCODE_PORT="3000"

RUN set -eux; \
    group_name="$(getent group "${GID}" | cut -d: -f1 || true)"; \
    if [ -z "$group_name" ]; then \
        groupadd --gid "${GID}" opencode; \
    fi; \
    user_name="$(getent passwd "${UID}" | cut -d: -f1 || true)"; \
    if [ -z "$user_name" ]; then \
        useradd --uid "${UID}" --gid "${GID}" --home-dir /home --shell /bin/bash --no-create-home opencode; \
    else \
        usermod --gid "${GID}" --home /home --shell /bin/bash "$user_name"; \
    fi; \
    chown -R "${UID}:${GID}" /home

WORKDIR /home

USER ${UID}:${GID}

CMD ["bash", "-c", "exec /home/.opencode/bin/opencode web --hostname 0.0.0.0 --port ${OPENCODE_PORT:-3000}"]

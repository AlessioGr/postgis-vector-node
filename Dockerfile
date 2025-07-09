FROM ghcr.io/payloadcms/postgis-vector:latest

LABEL org.opencontainers.image.title="postgis-vector-node" \
      org.opencontainers.image.description="postgresql+postgis+node container with pgvector added" \
      org.opencontainers.image.vendor="Payload" \
      org.opencontainers.image.authors="Payload <dev@payloadcms.com>" \
      org.opencontainers.image.version="1.0.0" \
      org.opencontainers.image.licenses="MIT" \
      org.opencontainers.image.url="https://github.com/AlessioGr/postgis-vector-node" \
      org.opencontainers.image.source="https://github.com/AlessioGr/postgis-vector-node"

# ---- Install system dependencies ----
RUN apt-get update && \
    apt-get install -y --no-install-recommends \
        ca-certificates curl gnupg xz-utils && \
    rm -rf /var/lib/apt/lists/*

# ---- Install Node.js 24.4.0 manually (exact version pin) ----
ENV NODE_VERSION=24.4.0
RUN curl -fsSL https://nodejs.org/dist/v${NODE_VERSION}/node-v${NODE_VERSION}-linux-x64.tar.xz \
        -o /tmp/node.tar.xz && \
    mkdir -p /usr/local/lib/nodejs && \
    tar -xJf /tmp/node.tar.xz -C /usr/local/lib/nodejs && \
    ln -sf /usr/local/lib/nodejs/node-v${NODE_VERSION}-linux-x64/bin/* /usr/local/bin/ && \
    rm /tmp/node.tar.xz

# ---- Install pnpm ----
RUN npm install -g pnpm@9.15.6
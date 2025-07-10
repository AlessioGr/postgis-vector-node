# syntax=docker/dockerfile:1.7

############################
# Stage 1: Node.js + pnpm #
############################

LABEL org.opencontainers.image.title="postgis-vector-node" \
      org.opencontainers.image.description="postgresql+postgis+node container with pgvector added" \
      org.opencontainers.image.vendor="Payload" \
      org.opencontainers.image.authors="Payload <dev@payloadcms.com>" \
      org.opencontainers.image.version="1.3.0" \
      org.opencontainers.image.licenses="MIT" \
      org.opencontainers.image.url="https://github.com/AlessioGr/postgis-vector-node" \
      org.opencontainers.image.source="https://github.com/AlessioGr/postgis-vector-node"

FROM --platform=linux/amd64 debian:bookworm AS node-builder

ARG NODE_VERSION=24.4.0
ENV NODE_DIR=/usr/local/lib/nodejs/node-v${NODE_VERSION}-linux-x64

RUN apt-get update && apt-get install -y --no-install-recommends \
    curl xz-utils ca-certificates && \
    curl -fsSL "https://nodejs.org/dist/v${NODE_VERSION}/node-v${NODE_VERSION}-linux-x64.tar.xz" -o /tmp/node.tar.xz && \
    mkdir -p /usr/local/lib/nodejs && \
    tar -xJf /tmp/node.tar.xz -C /usr/local/lib/nodejs && \
    ln -sf ${NODE_DIR}/bin/* /usr/local/bin/ && \
    npm config set prefix /usr/local && \
    npm install -g pnpm@9.15.6 && \
    rm /tmp/node.tar.xz && \
    apt-get purge -y curl xz-utils && apt-get autoremove -y && apt-get clean

############################
# Stage 2: Final container #
############################

FROM --platform=$BUILDPLATFORM ghcr.io/payloadcms/postgis-vector:latest AS base
ARG TARGETARCH

# Optional sanity check
RUN echo "Detected TARGETARCH=$TARGETARCH, uname=$(uname -m)"

# Copy in Node.js and pnpm from the amd64-built stage (safe for both archs)
COPY --from=node-builder /usr/local/lib/nodejs /usr/local/lib/nodejs
COPY --from=node-builder /usr/local/bin/node /usr/local/bin/node
COPY --from=node-builder /usr/local/bin/npm /usr/local/bin/npm
COPY --from=node-builder /usr/local/bin/npx /usr/local/bin/npx
COPY --from=node-builder /usr/local/bin/pnpm /usr/local/bin/pnpm
COPY --from=node-builder /usr/local/bin/corepack /usr/local/bin/corepack

# Workdir
WORKDIR /app

# Preinstall deps
COPY package.json pnpm-lock.yaml ./
COPY ./*.tgz ./
RUN pnpm install --frozen-lockfile

# Copy source and build
COPY . .
RUN pnpm build --experimental-build-mode compile

# Replace postgres entrypoint with node wrapper
RUN mv /usr/local/bin/docker-entrypoint.sh /usr/local/bin/postgres-entrypoint.sh
COPY docker-entrypoint.sh /usr/local/bin/docker-entrypoint.sh
RUN chmod +x /usr/local/bin/docker-entrypoint.sh

# Expose ports
EXPOSE 5432 3000

ENTRYPOINT ["docker-entrypoint.sh"]

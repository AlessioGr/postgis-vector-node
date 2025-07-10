# syntax=docker/dockerfile:1.7
ARG TARGETARCH=amd64
FROM --platform=$BUILDPLATFORM ghcr.io/payloadcms/postgis-vector:latest AS base

# declare again for the second stage
ARG TARGETARCH=amd64
FROM base

RUN echo "TARGETARCH=$TARGETARCH" && uname -m


LABEL org.opencontainers.image.title="postgis-vector-node" \
      org.opencontainers.image.description="postgresql+postgis+node container with pgvector added" \
      org.opencontainers.image.vendor="Payload" \
      org.opencontainers.image.authors="Payload <dev@payloadcms.com>" \
      org.opencontainers.image.version="1.2.0" \
      org.opencontainers.image.licenses="MIT" \
      org.opencontainers.image.url="https://github.com/AlessioGr/postgis-vector-node" \
      org.opencontainers.image.source="https://github.com/AlessioGr/postgis-vector-node"

# ---- system deps ----
RUN --mount=type=cache,target=/var/cache/apt \
    apt-get update && \
    apt-get install -y --no-install-recommends ca-certificates curl xz-utils \
    && rm -rf /var/lib/apt/lists/*

# ---- Node 24.4.0, correct architecture -------------------------------------
ARG TARGETARCH
ENV NODE_VERSION=24.4.0
RUN set -eux; \
    case "${TARGETARCH}" in \
      amd64) NODE_ARCH=x64 ;; \
      arm64) NODE_ARCH=arm64 ;; \
      *)     echo "Unsupported arch ${TARGETARCH}" && exit 1 ;; \
    esac && \
    curl -fsSL "https://nodejs.org/dist/v${NODE_VERSION}/node-v${NODE_VERSION}-linux-${NODE_ARCH}.tar.xz" \
      -o /tmp/node.tar.xz && \
    mkdir -p /usr/local/lib/nodejs && \
    tar -xJf /tmp/node.tar.xz -C /usr/local/lib/nodejs && \
    ln -sf /usr/local/lib/nodejs/node-v${NODE_VERSION}-linux-${NODE_ARCH}/bin/* /usr/local/bin/ && \
    rm /tmp/node.tar.xz

# ---- Install pnpm ----
RUN npm config set prefix /usr/local && \
    npm install -g pnpm@9.15.6

# check and print pnpm version. This ensures pnpm is installed correctly
RUN pnpm --version
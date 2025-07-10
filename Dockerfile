# syntax=docker/dockerfile:1.7
# -------------------------------------------------------------
# Image: ghcr.io/payloadcms/postgis-vector + Node + pnpm
# Multi‑arch: linux/amd64, linux/arm64
# Node: 24.4.0   |   pnpm: 9.15.6
# -------------------------------------------------------------
ARG TARGETPLATFORM
# amd64 | arm64
ARG TARGETARCH

FROM --platform=$TARGETPLATFORM ghcr.io/payloadcms/postgis-vector:latest

# ---- basic tooling ----------------------------------------------------------
RUN apt-get update -qq \
 && DEBIAN_FRONTEND=noninteractive apt-get install -y --no-install-recommends \
      ca-certificates curl xz-utils gnupg \
 && rm -rf /var/lib/apt/lists/*

# ---- Node.js ---------------------------------------------------------------
ARG TARGETARCH
ENV NODE_VERSION=24.4.0

RUN set -eux ; \
    case "$TARGETARCH" in \
      amd64) NODE_ARCH=x64  ;; \
      arm64) NODE_ARCH=arm64;; \
      *)     echo "Unsupported arch: $TARGETARCH" && exit 1 ;; \
    esac ; \
    curl -fsSL "https://nodejs.org/dist/v${NODE_VERSION}/node-v${NODE_VERSION}-linux-${NODE_ARCH}.tar.xz" -o /tmp/node.tar.xz ; \
    tar -xJf /tmp/node.tar.xz -C /usr/local --strip-components=1 --no-same-owner ; \
    rm /tmp/node.tar.xz ; \
    # make sure everything is on the PATH
    ln -sf /usr/local/bin/node  /usr/bin/node  ; \
    ln -sf /usr/local/bin/npm   /usr/bin/npm   ; \
    ln -sf /usr/local/bin/npx   /usr/bin/npx

# ---- pnpm (regular CLI, no Corepack) ---------------------------------------
ENV PNPM_VERSION=9.15.6

# install + sanity check
RUN npm install -g "pnpm@${PNPM_VERSION}" \
 && pnpm --version

# ---- metadata --------------------------------------------------------------
LABEL org.opencontainers.image.title="postgis-vector-node" \
      org.opencontainers.image.description="PostgreSQL+PostGIS+pgvector with Node & pnpm" \
      org.opencontainers.image.vendor="Payload" \
      org.opencontainers.image.authors="Payload <dev@payloadcms.com>" \
      org.opencontainers.image.version="1.5.0" \
      org.opencontainers.image.licenses="MIT"


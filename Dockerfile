# syntax=docker/dockerfile:1.7
FROM --platform=$BUILDPLATFORM ghcr.io/payloadcms/postgis-vector:latest AS base
ARG TARGETARCH

FROM base AS final
ARG TARGETARCH

RUN echo "BUILDPLATFORM=$BUILDPLATFORM  TARGETARCH=$TARGETARCH  HOSTARCH=$(uname -m)"

LABEL org.opencontainers.image.title="postgis-vector-node" \
      org.opencontainers.image.description="postgresql+postgis+node container with pgvector added" \
      org.opencontainers.image.vendor="Payload" \
      org.opencontainers.image.authors="Payload <dev@payloadcms.com>" \
      org.opencontainers.image.version="1.4.0" \
      org.opencontainers.image.licenses="MIT" \
      org.opencontainers.image.url="https://github.com/AlessioGr/postgis-vector-node" \
      org.opencontainers.image.source="https://github.com/AlessioGr/postgis-vector-node"

# ---- system deps ----
RUN apt-get update && \
    apt-get install -y --no-install-recommends ca-certificates curl xz-utils && \
    rm -rf /var/lib/apt/lists/*

# ---- Node 24.4.0, correct architecture ----
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

# ---- Install pnpm via static binary ----
ARG TARGETARCH
RUN set -eux; \
    case "${TARGETARCH}" in \
      amd64) PNPM_ARCH=x64 ;; \
      arm64) PNPM_ARCH=arm64 ;; \
      *)     echo "Unsupported arch ${TARGETARCH}" && exit 1 ;; \
    esac && \
    curl -fL "https://github.com/pnpm/pnpm/releases/download/v9.15.6/pnpm-linux-${PNPM_ARCH}" \
      -o /usr/local/bin/pnpm && \
    chmod +x /usr/local/bin/pnpm


RUN ln -s /usr/local/bin/pnpm /usr/bin/pnpm

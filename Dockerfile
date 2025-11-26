ARG BASE_IMAGE=ghcr.io/loong64/anolis:23
FROM ${BASE_IMAGE} AS builder
ARG TARGETARCH

RUN set -ex \
    && dnf -y install dnf-plugins-core \
    && \
    case "${TARGETARCH}" in \
        loong64|riscv64) \
            dnf install -y python3-devel; \
            python3 -m venv /opt/python; \
            ;; \
        *) \
            dnf config-manager --set-enabled powertools; \
            dnf install -y python39-devel; \
            python3.9 -m venv /opt/python; \
            ;; \
    esac \
    && dnf install -y cmake git gcc-c++ zlib-devel \
    && dnf clean all

# Clang
ARG RUNNER_ARCH
RUN set -ex \
    && \
    case "${TARGETARCH}" in \
        amd64|arm64) \
            mkdir -p /opt/clang/bin; \
            ;; \
        *) \
            curl -sSL https://github.com/loong64/static-clang-build/raw/refs/heads/main/install-static-clang.sh | bash; \
            ;; \
    esac

ENV PATH="/opt/clang/bin:/opt/python/bin:$PATH"
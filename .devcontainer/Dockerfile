FROM mcr.microsoft.com/devcontainers/base:jammy

# System packages needed to build/run the emitted C++ code and to format
# generated sources (make emit-cpp / emit-rust use clang-format / cargo fmt
# if present, but only clang-format needs to come from apt).
RUN apt-get update && export DEBIAN_FRONTEND=noninteractive \
    && apt-get -y install --no-install-recommends \
        build-essential \
        clang-format \
        ca-certificates \
        curl \
        git \
        pkg-config \
        libssl-dev \
    && apt-get clean -y \
    && rm -rf /var/lib/apt/lists/*

USER vscode

# elan is Lean's toolchain manager: it reads the repo's lean-toolchain file
# and transparently installs/selects the matching Lean version on first use,
# so we don't hardcode a Lean version here.
ENV ELAN_HOME=/home/vscode/.elan
ENV PATH=${ELAN_HOME}/bin:${PATH}
RUN curl https://raw.githubusercontent.com/leanprover/elan/master/elan-init.sh -sSf \
        | sh -s -- -y --default-toolchain none --no-modify-path

USER root

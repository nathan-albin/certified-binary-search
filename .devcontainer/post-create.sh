#!/usr/bin/env bash
# Runs once after the devcontainer is created: pulls in the Lean toolchain +
# Mathlib, prefetches Rust crates, and does a full build/test as a sanity
# check that the environment actually works end to end.
set -euo pipefail
cd "$(dirname "${BASH_SOURCE[0]}")/.."

echo "==> Installing pinned Lean toolchain ($(cat lean-toolchain))"
elan toolchain install "$(cat lean-toolchain)"

echo "==> Fetching prebuilt Mathlib oleans (skips a from-source Mathlib build)"
lake exe cache get || echo "warning: cache fetch failed/unavailable, 'lake build' will build Mathlib from source instead"

echo "==> Building the Lean project and emitter executables"
lake build

echo "==> Prefetching Rust crates"
cargo fetch --manifest-path emit/rust/Cargo.toml

echo "==> Sanity check: build and run the emitted C++ and Rust tests"
make test-cpp
make test-rust

echo "==> devcontainer setup complete"

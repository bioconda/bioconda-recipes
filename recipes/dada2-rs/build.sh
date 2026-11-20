#!/bin/bash
set -xeuo pipefail

# Bundle the licenses of every vendored Rust dependency.
cargo-bundle-licenses --format yaml --output THIRDPARTY.yml

# Portable build: no target-cpu flags, so the binary runs on any CPU of the
# platform. The GitHub release binaries are tuned (x86-64-v3) and faster.
export CARGO_PROFILE_RELEASE_STRIP=true
cargo install --no-track --locked --verbose --root "${PREFIX}" --path .

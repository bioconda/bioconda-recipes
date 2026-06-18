#!/bin/bash
set -euxo pipefail

# salmon 2.0 (Rust) bioconda build.
#
# The workspace builds the `salmon` binary from the `salmon-cli` crate. The
# committed Cargo.lock pins exact dependency versions (cf1-rs, piscem-rs, ksw2rs
# from crates.io), so `--locked` gives a reproducible build.

export CARGO_NET_GIT_FETCH_WITH_CLI=true

# Bundle third-party license texts for the package (bioconda policy for Rust).
cargo-bundle-licenses --format yaml --output THIRDPARTY.yml

# The repo's .cargo/config.toml pins a portable SIMD floor (x86-64-v2 / aarch64
# NEON); the alignment kernel (ksw2rs) still selects AVX2/SSE4.1/NEON at runtime.
# x86-64-v2 (SSE4.2, ~2009+) is the floor — note this if a broader baseline is
# ever required for the conda channel.
cargo install \
  --no-track \
  --locked \
  --bins \
  --root "${PREFIX}" \
  --path crates/salmon-cli

# `salmon-cli` installs a binary named `salmon` (see its [[bin]] name).

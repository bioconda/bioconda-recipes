#!/usr/bin/env bash
set -euo pipefail

# The upstream repository deliberately uses target-cpu=native for local
# profiling. Redistributed Conda packages instead use the compiler toolchain's
# portable target flags and ANTISEQUENCE's SSE2/NEON baseline matcher.
cp .cargo/config-baseline.toml .cargo/config.toml

cargo-bundle-licenses --format yaml --output THIRDPARTY.yml
cargo install -v --locked --no-track --root "${PREFIX}" --path . \
  --no-default-features --features antisequence/baseline-simd

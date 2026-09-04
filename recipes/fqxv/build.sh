#!/bin/bash
set -euo pipefail

# .cargo/config.toml pins target-cpu=x86-64-v3 as a [target.<triple>] rustflags
# entry, but only for x86_64-unknown-linux-gnu (the linux-64 build). That config
# source OUTRANKS build.rustflags/CARGO_BUILD_RUSTFLAGS, so it must be overridden
# with RUSTFLAGS (higher precedence) to get a portable baseline binary. AVX2 fast
# paths runtime-dispatch, so this loses nothing. Scope the override to linux-64;
# on aarch64/osx-arm64 there is no pin to override and "x86-64" is not a valid
# target-cpu there.
if [ "${target_platform}" == "linux-64" ]; then
  export RUSTFLAGS="-C target-cpu=x86-64"
fi

cargo-bundle-licenses --format yaml --output THIRDPARTY.yml

RUST_BACKTRACE=1 cargo install --no-track --locked --verbose --root "${PREFIX}" --path crates/fqxv-cli

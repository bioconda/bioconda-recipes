#!/bin/bash
set -euxo pipefail

# Use conda's Rust compiler instead of the upstream development toolchain pin.
rm -f rust-toolchain.toml

# Preserve compiler activation flags; upstream does not set target-cpu flags.
export CARGO_PROFILE_RELEASE_DEBUG=false
export CARGO_PROFILE_RELEASE_STRIP=symbols
export CARGO_BUILD_JOBS="${CPU_COUNT}"
export CARGO_NET_GIT_FETCH_WITH_CLI=true
export CARGO_NET_RETRY=5

# Include licenses for the Rust dependencies linked into the extension.
cargo-bundle-licenses --format yaml --output THIRDPARTY.yml

"${PYTHON}" -m pip install . -vv --no-deps --no-build-isolation \
    --config-settings=build-args=--locked

#!/bin/bash
set -euxo pipefail

export CARGO_NET_GIT_FETCH_WITH_CLI=true
export CARGO_NET_RETRY=10
export CARGO_HOME="${BUILD_PREFIX}/.cargo"

# Download Rust dependencies
cargo fetch --locked
export CARGO_NET_OFFLINE=true

# Generate third-party license report
cargo-bundle-licenses \
    --format yaml \
    --output THIRDPARTY.yml

# Build Python extension
maturin build \
    --manifest-path Cargo.toml \
    --interpreter "${PYTHON}" \
    --release \
    --strip \
    --locked \
    --offline \
    --out dist

# Install generated wheel
"${PYTHON}" -m pip install \
    dist/*.whl \
    --no-deps \
    --no-build-isolation \
    --no-cache-dir \
    -vvv

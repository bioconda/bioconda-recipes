#!/bin/bash

set -exuo pipefail

export CARGO_NET_GIT_FETCH_WITH_CLI=true
export CARGO_NET_RETRY=10
export CARGO_HOME="${BUILD_PREFIX}/.cargo"
export RUST_BACKTRACE=1

cargo fetch --locked
export CARGO_NET_OFFLINE=true

cargo-bundle-licenses --format yaml --output THIRDPARTY.yml

cargo install \
    --verbose \
    --locked \
    --offline \
    --no-track \
    --path kmertools \
    --root "${PREFIX}"

maturin build \
    --manifest-path ./conda/Cargo.toml \
    --bindings pyo3 \
    --interpreter "${PYTHON}" \
    --release \
    --strip \
    --locked \
    --offline

"${PYTHON}" -m pip install \
    ./target/wheels/*.whl \
    --no-deps \
    --no-build-isolation \
    --no-cache-dir \
    -vvv

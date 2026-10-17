#!/bin/bash
set -euo pipefail

export CARGO_HOME="${BUILD_PREFIX}/.cargo"
export OPENSSL_NO_VENDOR=1
export LIBZ_SYS_STATIC=0
export LIBCLANG_PATH=$(find "${BUILD_PREFIX}" -name "libclang.so*" | head -1 | xargs dirname)

cargo-bundle-licenses --format yaml --output THIRDPARTY.yml
cargo install --locked --no-track --root "${PREFIX}" --path .
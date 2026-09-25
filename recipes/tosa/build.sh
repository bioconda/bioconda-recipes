#!/bin/bash
set -euo pipefail

export CARGO_HOME="${SRC_DIR}/.cargo"
export LIBCLANG_PATH="${PREFIX}/lib"
export OPENSSL_DIR="${PREFIX}"
export OPENSSL_NO_VENDOR=1

cargo-bundle-licenses --format yaml --output "${SRC_DIR}/THIRDPARTY.yml"
cargo install --locked --path . --root "${PREFIX}"

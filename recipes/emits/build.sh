#!/bin/bash
set -euxo pipefail

export CARGO_HOME="${BUILD_PREFIX}/.cargo"
export CARGO_TARGET_DIR="${SRC_DIR}/target"

cargo build --release --verbose 2>&1

mkdir -p "${PREFIX}/bin"
install -m 755 "${CARGO_TARGET_DIR}/release/emits" "${PREFIX}/bin/emits"
#!/usr/bin/env bash
set -euxo pipefail

cargo-bundle-licenses --format yaml --output "${SRC_DIR}/THIRDPARTY.yml"
cargo install --locked --no-track --root "${PREFIX}" --path crates/nlr-cli

mkdir -p "${PREFIX}/licenses"
cp "${SRC_DIR}/THIRDPARTY.yml" "${PREFIX}/licenses/THIRDPARTY.yml"

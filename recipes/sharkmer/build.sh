#!/bin/bash
set -euo pipefail

# $SRC_DIR is the tarball root (sharkmer-1.0.x/)
# The Rust crate is one level deeper
cd "${SRC_DIR}/sharkmer"

mkdir -p licenses
cargo-bundle-licenses --format json --output "${RECIPE_DIR}/LICENSE.dependencies.json"

cp "${SRC_DIR}/sharkmer/LICENSE" "${RECIPE_DIR}/LICENSE"

cargo install --locked --no-track --root "${PREFIX}" --path .

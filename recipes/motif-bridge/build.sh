#!/bin/bash
set -euo pipefail

tar -xzf "${PKG_NAME}-${PKG_VERSION}.crate"
cd "${PKG_NAME}-${PKG_VERSION}"
cargo-bundle-licenses --format yaml --output THIRDPARTY.yml
cargo install --locked --no-track --root "$PREFIX" --path .

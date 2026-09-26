#!/usr/bin/env bash
set -euo pipefail

cargo-bundle-licenses --format yaml --output THIRDPARTY.yml
cargo install -v --locked --no-track --root "${PREFIX}" --path .
rm -f "${PREFIX}/.crates.toml" "${PREFIX}/.crates2.json"

mkdir -p "${PREFIX}/share/${PKG_NAME}/schema"
install -m644 schema/fastaguard.schema.json \
  "${PREFIX}/share/${PKG_NAME}/schema/fastaguard.schema.json"
install -m644 schema/finding-catalog.json \
  "${PREFIX}/share/${PKG_NAME}/schema/finding-catalog.json"

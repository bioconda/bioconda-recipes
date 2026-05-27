#!/usr/bin/env bash
set -euxo pipefail

export CARGO_HOME="${BUILD_PREFIX}/cargo"
mkdir -p "${CARGO_HOME}"

cargo-bundle-licenses --format yaml --output THIRDPARTY.yml

cargo install -v --locked --no-track --root "${PREFIX}" --path .

rm -f "${PREFIX}/.crates.toml" "${PREFIX}/.crates2.json"
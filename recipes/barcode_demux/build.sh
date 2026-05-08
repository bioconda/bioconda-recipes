#!/usr/bin/env bash
set -euxo pipefail

export CARGO_HOME="${BUILD_PREFIX}/cargo"
mkdir -p "${CARGO_HOME}"

cargo install --locked --root "${PREFIX}" --path .

rm -f "${PREFIX}/.crates.toml" "${PREFIX}/.crates2.json"
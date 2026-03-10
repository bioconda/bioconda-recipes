#!/bin/bash
set -euo pipefail

export CARGO_HOME="${BUILD_PREFIX}/.cargo"

cargo-bundle-licenses --format yaml --output THIRDPARTY.yml
cargo install --locked --no-track --root "${PREFIX}" --path .

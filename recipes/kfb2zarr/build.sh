#!/usr/bin/env bash
set -euxo pipefail

export CARGO_NET_GIT_FETCH_WITH_CLI=true
export CARGO_HOME="${SRC_DIR}/.cargo"

cargo-bundle-licenses --format yaml --output THIRDPARTY.yml
cargo install -v --locked --no-track --root "${PREFIX}" --path .

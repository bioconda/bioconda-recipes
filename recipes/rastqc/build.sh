#!/bin/bash
set -euo pipefail

export CARGO_HOME="${SRC_DIR}/.cargo"
export CARGO_NET_GIT_FETCH_WITH_CLI=true

cargo install --no-track --locked --root "${PREFIX}" --path . --bin rastqc

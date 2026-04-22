#!/bin/bash
set -euo pipefail

export CARGO_HOME="${SRC_DIR}/.cargo"

cargo install --no-track --locked --root "${PREFIX}" --path . --bin rastqc

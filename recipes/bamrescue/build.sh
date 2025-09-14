#!/bin/bash
set -euo pipefail

export CARGO_TERM_COLOR=never
export RUSTFLAGS="-C target-cpu=generic"

export CARGO_HOME="$SRC_DIR/.cargo"
mkdir -p "$CARGO_HOME"

cargo install --locked --path . --root "${PREFIX}"
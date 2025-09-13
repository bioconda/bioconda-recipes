#!/bin/bash
set -euo pipefail

export CARGO_TERM_COLOR=never
export RUSTFLAGS="-C target-cpu=generic"

export CARGO_HOME="$SRC_DIR/.cargo"
mkdir -p "$CARGO_HOME"

cargo build --release --locked

install -d "${PREFIX}/bin"
install -m 0755 target/release/bamrescue "${PREFIX}/bin/"
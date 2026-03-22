#!/bin/bash
set -euxo pipefail

export CARGO_HOME="${BUILD_PREFIX}/.cargo"

cargo build --release --verbose

mkdir -p "${PREFIX}/bin"
install -m 755 "target/x86_64-unknown-linux-gnu/release/emits" "${PREFIX}/bin/emits" \
  || install -m 755 "target/release/emits" "${PREFIX}/bin/emits"
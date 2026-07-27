#!/bin/bash
set -euo pipefail

export CFLAGS="${CFLAGS} -O3 -Wno-cpp -Wno-unused-function -Wno-implicit-function-declaration -Wno-int-conversion"

# build statically linked binary with Rust
RUST_BACKTRACE=1 cargo install \
    --verbose \
    --locked \
    --no-track \
    --path . \
    --root "${PREFIX}"

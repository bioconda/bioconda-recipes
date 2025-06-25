#!/bin/bash -euo
set -xe

export CFLAGS="${CFLAGS} -O3 -std=c11 -Wno-implicit-function-declaration"

# build statically linked binary with Rust
export RUST_BACKTRACE=1
cargo install --verbose --path . --root "${PREFIX}" --no-track

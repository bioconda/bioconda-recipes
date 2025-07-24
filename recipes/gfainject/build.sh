#!/bin/bash -euo

set -xe

export CFLAGS="${CFLAGS} -std=c11"

# build statically linked binary with Rust
export RUST_BACKTRACE=1
cargo install --verbose --path . --root "${PREFIX}" --no-track

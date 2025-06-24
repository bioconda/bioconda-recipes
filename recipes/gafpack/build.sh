#!/bin/bash -euo

set -xe

export CFLAGS="-std=c11 $CFLAGS"

# build statically linked binary with Rust
export RUST_BACKTRACE=1
cargo install --verbose --path . --root ${PREFIX} --no-track

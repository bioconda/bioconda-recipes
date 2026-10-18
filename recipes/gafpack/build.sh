#!/bin/bash -euo

set -xe

# build statically linked binary with Rust
export RUST_BACKTRACE=1
cargo install --verbose --path . --root ${PREFIX} --no-track

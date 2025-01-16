#!/bin/bash -euo

set -xe

# build statically linked binary with Rust
RUST_BACKTRACE=1
cargo install --verbose --path . --root ${PREFIX}

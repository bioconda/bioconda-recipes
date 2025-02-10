#!/bin/bash -ex

# build statically linked binary with Rust
RUST_BACKTRACE=1
cargo install --verbose --path=d4tools --root "${PREFIX}"

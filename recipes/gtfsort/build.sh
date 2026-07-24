#!/bin/bash

# build statically linked binary with Rust
RUST_BACKTRACE=1
cargo install --verbose --no-track --path gtfsort/ --root "${PREFIX}"

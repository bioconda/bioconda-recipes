#!/bin/bash -euo

# build statically linked binary with Rust
RUST_BACKTRACE=1 cargo install --profile=release --no-track --locked --verbose --root $PREFIX --path .

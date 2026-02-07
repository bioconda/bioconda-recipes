#!/bin/bash -euo

# build statically linked binary with Rust
RUST_BACKTRACE=1 cargo install --profile=ultra --verbose --root $PREFIX --path .

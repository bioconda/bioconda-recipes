#!/bin/bash -e

# build statically linked binary with Rust
RUST_BACKTRACE=1 LIBRARY_PATH=$PREFIX cargo install --root $PREFIX

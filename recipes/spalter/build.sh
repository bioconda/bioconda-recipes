#!/bin/bash -e

# build statically linked binary with Rust
LIBRARY_PATH=$PREFIX/lib cargo build --release
# install the binary
cp target/release/spalter $PREFIX/bin

#!/bin/bash -e

# Build statically linked binary with Rust
C_INCLUDE_PATH=$PREFIX/include \
LIBRARY_PATH=$PREFIX/lib \
cargo build --release

# Install the binary
mkdir -p ${PREFIX}/bin
cp target/release/smafa $PREFIX/bin

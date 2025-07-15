#!/bin/bash -e

cargo add rust-htslib@0.45

# Build statically linked binary with Rust
C_INCLUDE_PATH=$PREFIX/include \
LIBRARY_PATH=$PREFIX/lib \
cargo build --release

# Install the binaries
cargo install --root $PREFIX

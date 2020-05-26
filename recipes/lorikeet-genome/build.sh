#!/bin/bash -e

# Build statically linked binary with Rust
C_INCLUDE_PATH=$PREFIX/include \
LIBRARY_PATH=$PREFIX/lib \
LIBCLANG_PATH=$PREFIX/lib/libclang.so \
OPENSSL_DIR=$PREFIX/lib \
cargo build --release

# Install the binaries
cargo install --root $PREFIX

#!/bin/bash -e

mkdir -p ~/.cargo
# Build statically linked binary with Rust
C_INCLUDE_PATH=$PREFIX/include \
LIBRARY_PATH=$PREFIX/lib \
LD_LIBRARY_PATH=$PREFIX/lib \
LIBCLANG_PATH=$PREFIX/lib/libclang.so \
cargo build --release

# bundle license files
cargo-bundle-licenses --format yaml --output THIRDPARTY.yml

# Install the binaries
C_INCLUDE_PATH=$PREFIX/include \
LIBRARY_PATH=$PREFIX/lib \
LD_LIBRARY_PATH=$PREFIX/lib \
LIBCLANG_PATH=$PREFIX/lib/libclang.so \
cargo install -v --locked --no-track --path ./ --force --root $PREFIX

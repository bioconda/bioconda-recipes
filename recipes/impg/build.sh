#!/bin/bash -euo

set -xe

# Create symlinks for standard compiler names that AGC makefile expects
mkdir -p $BUILD_PREFIX/bin
ln -sf $CC $BUILD_PREFIX/bin/gcc
ln -sf $CXX $BUILD_PREFIX/bin/g++

# Ensure the symlinks are in PATH
export PATH="$BUILD_PREFIX/bin:$PATH"

# Also export the standard names
export CC=gcc
export CXX=g++

cargo-bundle-licenses --format yaml --output THIRDPARTY.yml

# build statically linked binary with Rust
RUST_BACKTRACE=1
cargo install -v --no-track --path . --root "${PREFIX}"

#!/bin/bash -euo
set -xe

# On macOS, AGC requires actual GCC, not clang
if [[ $(uname) == "Darwin" ]]; then
    # Set PLATFORM for ARM64 Macs as AGC expects
    if [[ $(uname -m) == "arm64" ]]; then
        export PLATFORM=arm8
    fi
    
    # AGC-rs needs actual GCC on macOS, not clang
    # The conda-forge gcc package provides this
    # We need to use the actual gcc/g++ binaries from conda
    export CC=$BUILD_PREFIX/bin/gcc
    export CXX=$BUILD_PREFIX/bin/g++
    
    # Set up Rust to use g++ as the linker
    export RUSTFLAGS="-C linker=$CXX"
    
    # Set make command for macOS
    export MAKE=make
else
    # Create symlinks for standard compiler names that AGC makefile expects
    mkdir -p $BUILD_PREFIX/bin
    ln -sf $CC $BUILD_PREFIX/bin/gcc
    ln -sf $CXX $BUILD_PREFIX/bin/g++

    # Ensure the symlinks are in PATH
    export PATH="$BUILD_PREFIX/bin:$PATH"

    # Also export the standard names
    export CC=gcc
    export CXX=g++
fi

cargo-bundle-licenses --format yaml --output THIRDPARTY.yml

# build statically linked binary with Rust
RUST_BACKTRACE=1
cargo install -v --no-track --path . --root "${PREFIX}"

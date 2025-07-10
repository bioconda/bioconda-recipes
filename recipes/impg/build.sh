#!/bin/bash -euo

set -xe

# On macOS, use clang directly without creating gcc symlinks
if [[ $(uname) == "Darwin" ]]; then
    # Use the actual clang/clang++ compilers
    export CC="${CC}"
    export CXX="${CXX}"
    
    # AGC makefile has strict version checks, so we might need to patch it
    # or set specific environment variables to bypass the check
    export PLATFORM=arm8  # For ARM64 Macs
else
    # Linux: Create symlinks for standard compiler names that AGC makefile expects
    mkdir -p $BUILD_PREFIX/bin
    ln -sf $CC $BUILD_PREFIX/bin/gcc
    ln -sf $CXX $BUILD_PREFIX/bin/g++
    
    # Ensure the symlinks are in PATH
    export PATH="$BUILD_PREFIX/bin:$PATH"
    
    # Export standard names
    export CC=gcc
    export CXX=g++
fi

cargo-bundle-licenses --format yaml --output THIRDPARTY.yml

# build statically linked binary with Rust
RUST_BACKTRACE=1
cargo install -v --no-track --path . --root "${PREFIX}"

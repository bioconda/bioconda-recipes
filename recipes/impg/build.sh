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
    mkdir -p "$PREFIX/bin"
    ln -sf $CC $PREFIX/bin/clang
    ln -sf $CXX $PREFIX/bin/clang++
    export CC="$PREFIX/bin/clang"
    export CXX="$PREFIX/bin/clang++"
    
    # Set up Rust to use g++ as the linker
    export RUSTFLAGS="-C linker=$CXX"
    
    # Set make command for macOS
    export MAKE=make
else
    # Create symlinks for standard compiler names that AGC makefile expects
    mkdir -p "$PREFIX/bin"
    ln -sf $CC "$PREFIX/bin/gcc"
    ln -sf $CXX "$PREFIX/bin/g++"

    # Ensure the symlinks are in PATH
    export PATH="$PREFIX/bin:$PATH"

    # Also export the standard names
    export CC="$PREFIX/bin/gcc"
    export CXX="$PREFIX/bin/g++"
fi

cargo-bundle-licenses --format yaml --output THIRDPARTY.yml

# build statically linked binary with Rust
RUST_BACKTRACE=1
cargo install -v --no-track --path . --root "${PREFIX}"

#!/bin/bash -euo
set -xe

# On macOS, AGC requires actual GCC, not clang
if [[ $(uname) == "Darwin" ]]; then
    # This disables AGC support. AGC requires a real GCC compiler, not clang.
    CARGO_EXTRA_FLAGS="--no-default-features"

    # Set PLATFORM for ARM64 Macs as AGC expects
    if [[ $(uname -m) == "arm64" ]]; then
        export PLATFORM=arm8
    fi
    
    # Use the conda-provided Clang compilers
    # CC and CXX are already set by conda to clang/clang++
    echo "Using CC: $CC"
    echo "Using CXX: $CXX"
    $CC --version || true
    $CXX --version || true
    
    # Remove any clang-specific flags that might cause issues
    export CXXFLAGS="${CXXFLAGS//-stdlib=libc++/}"
    export CFLAGS="${CFLAGS//-stdlib=libc++/}"
    
    # Use gmake if available, otherwise make
    if command -v gmake >/dev/null 2>&1; then
        export MAKE="gmake"
    else
        export MAKE="make"
    fi
else
    CARGO_EXTRA_FLAGS=""

    # Linux: Create symlinks for standard compiler names that AGC makefile expects
    mkdir -p "$BUILD_PREFIX/bin"
    ln -sf $CC "$BUILD_PREFIX/bin/gcc"
    ln -sf $CXX "$BUILD_PREFIX/bin/g++"

    # Ensure the symlinks are in PATH
    export PATH="$BUILD_PREFIX/bin:$PATH"

    # Also export the standard names
    export CC="$BUILD_PREFIX/bin/gcc"
    export CXX="$BUILD_PREFIX/bin/g++"
fi

# Debug: Print final compiler information
echo "Final CC: $CC"
echo "Final CXX: $CXX"
$CC --version || true
$CXX --version || true

# Only verify GCC on Linux where AGC support is enabled
if [[ $(uname) != "Darwin" ]]; then
    # Verify we have real GCC (check for either "GNU" or "gcc" in the output)
    if ! $CC --version 2>&1 | grep -qE "(GNU|gcc)"; then
        echo "ERROR: CC is not GNU GCC!"
        exit 1
    fi
fi

cargo-bundle-licenses --format yaml --output THIRDPARTY.yml

# build statically linked binary with Rust
RUST_BACKTRACE=1
cargo install -v --no-track --path . --root "${PREFIX}" ${CARGO_EXTRA_FLAGS}
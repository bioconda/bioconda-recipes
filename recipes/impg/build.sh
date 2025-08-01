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
    
    # The gfortran packages install real GCC alongside gfortran
    # Find the real GCC/G++ binaries
    GCC_BIN=""
    GXX_BIN=""
    
    # Look for GCC binaries with version suffixes (gfortran packages typically install as gcc-XX)
    for ver in 14 13 12 11; do
        if [[ -f "$BUILD_PREFIX/bin/gcc-${ver}" ]] && [[ -f "$BUILD_PREFIX/bin/g++-${ver}" ]]; then
            GCC_BIN="$BUILD_PREFIX/bin/gcc-${ver}"
            GXX_BIN="$BUILD_PREFIX/bin/g++-${ver}"
            echo "Found GCC version ${ver}"
            break
        fi
    done
    
    # If not found with version suffix, look for plain gcc/g++
    if [[ -z "$GCC_BIN" ]] || [[ -z "$GXX_BIN" ]]; then
        if [[ -f "$BUILD_PREFIX/bin/gcc" ]] && [[ -f "$BUILD_PREFIX/bin/g++" ]]; then
            # Verify these are real GCC, not clang wrappers
            if "$BUILD_PREFIX/bin/gcc" --version 2>&1 | grep -qE "(GNU|gcc)"; then
                GCC_BIN="$BUILD_PREFIX/bin/gcc"
                GXX_BIN="$BUILD_PREFIX/bin/g++"
            fi
        fi
    fi
    
    if [[ -z "$GCC_BIN" ]] || [[ -z "$GXX_BIN" ]]; then
        echo "ERROR: Could not find real GCC/G++ in conda environment"
        echo "Looking in: $BUILD_PREFIX/bin"
        echo "Available compilers:"
        ls -la "$BUILD_PREFIX/bin" | grep -E "(gcc|g\+\+)" || true
        exit 1
    fi
    
    export CC="$GCC_BIN"
    export CXX="$GXX_BIN"
    
    echo "Using CC: $CC"
    echo "Using CXX: $CXX"
    $CC --version || true
    $CXX --version || true
    
    # Set up environment for static linking
    export LDFLAGS="${LDFLAGS} -static-libgcc -static-libstdc++"
    
    # Set up Rust to use g++ as the linker
    export RUSTFLAGS="-C linker=${CXX}"
    
    # Remove any clang-specific flags
    export CXXFLAGS="${CXXFLAGS//-stdlib=libc++/}"
    export CFLAGS="${CFLAGS//-stdlib=libc++/}"
    
    # Use gmake if available, otherwise make
    if command -v gmake >/dev/null 2>&1; then
        export MAKE="gmake"
    else
        export MAKE="make"
    fi
    
    # Unset clang variables to avoid conflicts
    unset CLANG
    unset CLANGXX
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

# Verify we have real GCC (check for either "GNU" or "gcc" in the output)
if ! $CC --version 2>&1 | grep -qE "(GNU|gcc)"; then
    echo "ERROR: CC is not GNU GCC!"
    exit 1
fi

cargo-bundle-licenses --format yaml --output THIRDPARTY.yml

# build statically linked binary with Rust
RUST_BACKTRACE=1
cargo install -v --no-track --path . --root "${PREFIX}" ${CARGO_EXTRA_FLAGS}
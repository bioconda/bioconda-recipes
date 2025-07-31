#!/bin/bash -euo
set -xe

# On macOS, AGC requires actual GCC, not clang
if [[ $(uname) == "Darwin" ]]; then
    # Set PLATFORM for ARM64 Macs as AGC expects
    if [[ $(uname -m) == "arm64" ]]; then
        export PLATFORM=arm8
    fi
    
    # AGC-rs needs actual GCC on macOS, not clang
    # Override the conda-forge default compilers
    
    # First, try to find GCC/G++ in the environment
    GCC_BIN=""
    GXX_BIN=""
    
    # Check for gcc/g++ directly
    if command -v gcc >/dev/null 2>&1 && command -v g++ >/dev/null 2>&1; then
        GCC_BIN=$(command -v gcc)
        GXX_BIN=$(command -v g++)
    elif [[ -f "$BUILD_PREFIX/bin/gcc" ]] && [[ -f "$BUILD_PREFIX/bin/g++" ]]; then
        GCC_BIN="$BUILD_PREFIX/bin/gcc"
        GXX_BIN="$BUILD_PREFIX/bin/g++"
    else
        # Try to find versioned GCC binaries
        for ver in 14 13 12 11; do
            if [[ -f "$BUILD_PREFIX/bin/gcc-${ver}" ]] && [[ -f "$BUILD_PREFIX/bin/g++-${ver}" ]]; then
                GCC_BIN="$BUILD_PREFIX/bin/gcc-${ver}"
                GXX_BIN="$BUILD_PREFIX/bin/g++-${ver}"
                break
            fi
        done
    fi
    
    if [[ -z "$GCC_BIN" ]] || [[ -z "$GXX_BIN" ]]; then
        echo "ERROR: Could not find GCC/G++ in conda environment"
        echo "Available compilers in PATH:"
        which gcc || echo "gcc not found in PATH"
        which g++ || echo "g++ not found in PATH"
        echo "Available in BUILD_PREFIX:"
        ls -la "$BUILD_PREFIX/bin" | grep -E "(gcc|g\+\+|clang)" || true
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

cargo-bundle-licenses --format yaml --output THIRDPARTY.yml

# build statically linked binary with Rust
RUST_BACKTRACE=1
cargo install -v --no-track --path . --root "${PREFIX}"
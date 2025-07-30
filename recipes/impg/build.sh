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
    # Find the actual gcc/g++ binaries from conda
    
    # Look for versioned GCC binaries (conda-forge typically provides gcc-XX and g++-XX)
    GCC_VERSION=""
    for ver in 13 12 11; do
        if [ -f "$BUILD_PREFIX/bin/gcc-${ver}" ] && [ -f "$BUILD_PREFIX/bin/g++-${ver}" ]; then
            GCC_VERSION="${ver}"
            break
        fi
    done
    
    if [ -z "$GCC_VERSION" ]; then
        # Try to find any gcc/g++ binary
        if [ -f "$BUILD_PREFIX/bin/gcc" ] && [ -f "$BUILD_PREFIX/bin/g++" ]; then
            export CC="$BUILD_PREFIX/bin/gcc"
            export CXX="$BUILD_PREFIX/bin/g++"
        else
            echo "ERROR: Could not find GCC/G++ in conda environment"
            echo "Available compilers in $BUILD_PREFIX/bin:"
            ls -la "$BUILD_PREFIX/bin" | grep -E "(gcc|g\+\+|clang)" || true
            exit 1
        fi
    else
        export CC="$BUILD_PREFIX/bin/gcc-${GCC_VERSION}"
        export CXX="$BUILD_PREFIX/bin/g++-${GCC_VERSION}"
        echo "Using GCC version ${GCC_VERSION}"
    fi
    
    # Set up environment for static linking (following agc-rs approach)
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

# Debug: Print compiler information
echo "Using CC: $CC"
echo "Using CXX: $CXX"
$CC --version || true
$CXX --version || true

cargo-bundle-licenses --format yaml --output THIRDPARTY.yml

# build statically linked binary with Rust
RUST_BACKTRACE=1
cargo install -v --no-track --path . --root "${PREFIX}"
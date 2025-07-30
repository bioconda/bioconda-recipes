#!/bin/bash -euo
set -xe

# On macOS, AGC requires actual GCC, not clang
if [[ $(uname) == "Darwin" ]]; then
    # Set PLATFORM for ARM64 Macs as AGC expects
    if [[ $(uname -m) == "arm64" ]]; then
        export PLATFORM=arm8
    fi
    
    # AGC-rs needs actual GCC on macOS, not clang
    # Look for GCC from the gcc_impl packages
    GCC_BIN=""
    GXX_BIN=""
    
    # Search for GCC binaries - conda-forge gcc_impl packages install them with specific names
    for gcc_candidate in "$BUILD_PREFIX"/bin/*-gcc*; do
        if [[ -f "$gcc_candidate" ]] && [[ ! "$gcc_candidate" =~ -gcc-(ar|nm|ranlib) ]]; then
            GCC_BIN="$gcc_candidate"
            break
        fi
    done
    
    for gxx_candidate in "$BUILD_PREFIX"/bin/*-g++*; do
        if [[ -f "$gxx_candidate" ]]; then
            GXX_BIN="$gxx_candidate"
            break
        fi
    done
    
    # If not found with full names, try simpler patterns
    if [[ -z "$GCC_BIN" ]] || [[ -z "$GXX_BIN" ]]; then
        # On macOS ARM64, gcc_impl packages might install as aarch64-apple-darwin20.0.0-gcc
        if [[ $(uname -m) == "arm64" ]]; then
            GCC_BIN="${BUILD_PREFIX}/bin/aarch64-apple-darwin20.0.0-gcc"
            GXX_BIN="${BUILD_PREFIX}/bin/aarch64-apple-darwin20.0.0-g++"
        else
            GCC_BIN="${BUILD_PREFIX}/bin/x86_64-apple-darwin13.4.0-gcc"
            GXX_BIN="${BUILD_PREFIX}/bin/x86_64-apple-darwin13.4.0-g++"
        fi
    fi
    
    if [[ ! -f "$GCC_BIN" ]] || [[ ! -f "$GXX_BIN" ]]; then
        echo "ERROR: Could not find GCC/G++ in conda environment"
        echo "Looking for GCC in: $BUILD_PREFIX/bin"
        ls -la "$BUILD_PREFIX/bin" | grep -E "(gcc|g\+\+)" || true
        exit 1
    fi
    
    export CC="$GCC_BIN"
    export CXX="$GXX_BIN"
    
    echo "Using CC: $CC"
    echo "Using CXX: $CXX"
    
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

# Debug: Print compiler information
echo "Final CC: $CC"
echo "Final CXX: $CXX"
$CC --version || true
$CXX --version || true

cargo-bundle-licenses --format yaml --output THIRDPARTY.yml

# build statically linked binary with Rust
RUST_BACKTRACE=1
cargo install -v --no-track --path . --root "${PREFIX}"
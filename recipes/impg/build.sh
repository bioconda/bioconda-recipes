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
    echo "Using CC: $CC"
    echo "Using CXX: $CXX"
    $CC --version || true
    $CXX --version || true
    
    # Find the C++ standard library location
    LIBCXX_DIR="$BUILD_PREFIX/lib"
    if [[ ! -f "$LIBCXX_DIR/libc++.dylib" ]] && [[ ! -f "$LIBCXX_DIR/libc++.a" ]]; then
        # Try to find libc++ in the conda environment
        LIBCXX_DIR="$PREFIX/lib"
    fi
    
    # Set up Rust to use clang++ as the linker and link with libc++
    export RUSTFLAGS="-C linker=${CXX} -C link-arg=-L${LIBCXX_DIR} -C link-arg=-lc++ -C link-arg=-Wl,-rpath,${PREFIX}/lib"
    
    # Ensure C++ builds within cargo use the same settings
    export CMAKE_CXX_FLAGS="${CXXFLAGS}"
    export CMAKE_C_FLAGS="${CFLAGS}"
    export CMAKE_CXX_COMPILER="${CXX}"
    export CMAKE_C_COMPILER="${CC}"
    export CMAKE_PREFIX_PATH="${PREFIX}"
    
    # For builds that use pkg-config
    export PKG_CONFIG_ALLOW_CROSS=1
    
    # Ensure the C++ standard library is available
    export LDFLAGS="${LDFLAGS} -L${LIBCXX_DIR} -lc++"
    export LIBRARY_PATH="${LIBCXX_DIR}:${LIBRARY_PATH:-}"
    
    # NOTE: We do NOT set DYLD_LIBRARY_PATH as it can interfere with system tools
    # The rpath settings in RUSTFLAGS should be sufficient
    
    # For C++ builds that might not respect LDFLAGS
    export CXXFLAGS="${CXXFLAGS} -L${LIBCXX_DIR}"
    
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
echo "Final CXXFLAGS: $CXXFLAGS"
echo "Final LDFLAGS: $LDFLAGS"
echo "Final RUSTFLAGS: $RUSTFLAGS"
echo "Final CMAKE_CXX_FLAGS: ${CMAKE_CXX_FLAGS:-}"
echo "Final LIBRARY_PATH: ${LIBRARY_PATH:-}"
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

# Run cargo-bundle-licenses before setting up any special environment
# Save current environment
SAVED_LD_LIBRARY_PATH="${LD_LIBRARY_PATH:-}"
SAVED_DYLD_LIBRARY_PATH="${DYLD_LIBRARY_PATH:-}"

# Temporarily unset problematic variables for cargo-bundle-licenses
unset LD_LIBRARY_PATH
unset DYLD_LIBRARY_PATH

cargo-bundle-licenses --format yaml --output THIRDPARTY.yml

# Restore environment if needed (though we don't use DYLD_LIBRARY_PATH anymore)
export LD_LIBRARY_PATH="${SAVED_LD_LIBRARY_PATH}"

# build statically linked binary with Rust
RUST_BACKTRACE=1
cargo install -v --no-track --path . --root "${PREFIX}" ${CARGO_EXTRA_FLAGS}
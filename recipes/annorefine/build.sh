#!/bin/bash

set -ex

# Determine the Rust target based on the platform FIRST
if [[ "$(uname)" == "Darwin" ]]; then
    if [[ "$(uname -m)" == "arm64" ]]; then
        RUST_TARGET="aarch64-apple-darwin"
    else
        RUST_TARGET="x86_64-apple-darwin"
    fi
    # Set macOS deployment target for proper wheel compatibility
    export MACOSX_DEPLOYMENT_TARGET=11.0
else
    # Linux
    if [[ "$(uname -m)" == "aarch64" ]]; then
        RUST_TARGET="aarch64-unknown-linux-gnu"
    else
        RUST_TARGET="x86_64-unknown-linux-gnu"
    fi
fi

echo "Building for target: ${RUST_TARGET}"
echo "CC is: ${CC}"
echo "Build platform: $(uname) $(uname -m)"

# Set environment variables to use system OpenSSL instead of building from source
export OPENSSL_NO_VENDOR=1
export OPENSSL_DIR=$PREFIX
export OPENSSL_INCLUDE_DIR=$PREFIX/include
export OPENSSL_LIB_DIR=$PREFIX/lib
export PKG_CONFIG_PATH="${PREFIX}/lib/pkgconfig:${PREFIX}/share/pkgconfig:${PKG_CONFIG_PATH:-}"

# Set C include and library paths for Rust build
export C_INCLUDE_PATH=$PREFIX/include
export LIBRARY_PATH=$PREFIX/lib

# Set Rust backtrace for better error messages
export RUST_BACKTRACE=1

# Set LIBCLANG_PATH for bindgen (needed for rust-htslib)
# clangdev provides libclang but we want to use GCC for actual compilation
if [[ "$(uname)" != "Darwin" ]]; then
    export LIBCLANG_PATH="${BUILD_PREFIX}/lib"
fi

# CRITICAL: Set Cargo environment variables to force the correct target and linker
# This must be done BEFORE any cargo commands are run
export CARGO_BUILD_TARGET="${RUST_TARGET}"

# Set the linker for the specific target using environment variable
# This is the most reliable way to configure the linker
if [[ "${RUST_TARGET}" == "aarch64-unknown-linux-gnu" ]]; then
    export CARGO_TARGET_AARCH64_UNKNOWN_LINUX_GNU_LINKER="${CC}"
    echo "Set CARGO_TARGET_AARCH64_UNKNOWN_LINUX_GNU_LINKER=${CC}"
elif [[ "${RUST_TARGET}" == "x86_64-unknown-linux-gnu" ]]; then
    export CARGO_TARGET_X86_64_UNKNOWN_LINUX_GNU_LINKER="${CC}"
    echo "Set CARGO_TARGET_X86_64_UNKNOWN_LINUX_GNU_LINKER=${CC}"
fi

# Create .cargo/config.toml to explicitly configure the linker for the target
# This is a backup to the environment variables above
mkdir -p .cargo
cat > .cargo/config.toml <<EOF
[target.${RUST_TARGET}]
linker = "${CC}"

[build]
target = "${RUST_TARGET}"
EOF
echo "Created .cargo/config.toml:"
cat .cargo/config.toml

# Bundle licenses for Rust dependencies
cargo-bundle-licenses --format yaml --output THIRDPARTY.yml

# Build the package using maturin - should produce *.whl files
maturin build --interpreter "${PYTHON}" -b pyo3 --release --strip --manylinux off --target "${RUST_TARGET}"

# Debug: Check what binary format was produced
echo "=== Checking binary format of built artifacts ==="
if command -v file &> /dev/null; then
    find target -name "*.so" -o -name "annorefine" | while read f; do
        echo "File: $f"
        file "$f"
    done
fi
if command -v readelf &> /dev/null; then
    find target -name "*.so" | while read f; do
        echo "ELF header for: $f"
        readelf -h "$f" 2>&1 | head -20 || echo "Not an ELF file"
    done
fi
echo "=== End binary format check ==="

# Install *.whl files using pip
${PYTHON} -m pip install target/wheels/*.whl --no-deps --no-build-isolation --no-cache-dir -vv


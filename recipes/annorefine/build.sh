#!/bin/bash

set -ex

# Set macOS deployment target for proper wheel compatibility
if [[ "$(uname)" == "Darwin" ]]; then
    export MACOSX_DEPLOYMENT_TARGET=11.0
fi

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

# Bundle licenses for Rust dependencies
cargo-bundle-licenses --format yaml --output THIRDPARTY.yml

# Determine the Rust target based on the platform
if [[ "$(uname)" == "Darwin" ]]; then
    if [[ "$(uname -m)" == "arm64" ]]; then
        RUST_TARGET="aarch64-apple-darwin"
    else
        RUST_TARGET="x86_64-apple-darwin"
    fi
else
    # Linux
    if [[ "$(uname -m)" == "aarch64" ]]; then
        RUST_TARGET="aarch64-unknown-linux-gnu"
    else
        RUST_TARGET="x86_64-unknown-linux-gnu"
    fi
fi

# Build the package using maturin - should produce *.whl files
maturin build --interpreter "${PYTHON}" -b pyo3 --release --strip --manylinux off --target "${RUST_TARGET}"

# Install *.whl files using pip
${PYTHON} -m pip install target/wheels/*.whl --no-deps --no-build-isolation --no-cache-dir -vv


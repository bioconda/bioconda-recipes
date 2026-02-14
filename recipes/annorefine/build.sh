#!/bin/bash

set -ex

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

# Bundle licenses for Rust dependencies
cargo-bundle-licenses --format yaml --output THIRDPARTY.yml

# Build the package using maturin - should produce *.whl files
maturin build --interpreter "${PYTHON}" -b pyo3 --release --strip --manylinux off

# Install *.whl files using pip
${PYTHON} -m pip install target/wheels/*.whl --no-deps --no-build-isolation --no-cache-dir -vv


#!/bin/bash

set -ex

# Set environment variables to use system OpenSSL instead of building from source
export OPENSSL_NO_VENDOR=1
export OPENSSL_DIR=$PREFIX
export OPENSSL_INCLUDE_DIR=$PREFIX/include
export OPENSSL_LIB_DIR=$PREFIX/lib

# Bundle licenses for Rust dependencies
cargo-bundle-licenses --format yaml --output THIRDPARTY.yml

# Install using pip
${PYTHON} -m pip install . -vvv --no-deps --no-build-isolation --no-cache-dir


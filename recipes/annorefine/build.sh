#!/bin/bash

set -euo pipefail

# Set macOS deployment target for proper wheel compatibility
if [[ "$(uname)" == "Darwin" ]]; then
    export MACOSX_DEPLOYMENT_TARGET=11.0
fi

# Set LIBCLANG_PATH for bindgen (needed for rust-htslib)
if [[ "$(uname)" != "Darwin" ]]; then
    export LIBCLANG_PATH="${BUILD_PREFIX}/lib"
fi

# Bundle licenses for Rust dependencies
cargo-bundle-licenses --format yaml --output THIRDPARTY.yml

# Build using maturin - produces *.whl files
export RUST_BACKTRACE=1
maturin build --interpreter "${PYTHON}" -b pyo3 --release --strip --manylinux off

# Install *.whl files using pip
${PYTHON} -m pip install target/wheels/*.whl --no-deps --no-build-isolation --no-cache-dir -vv


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

# Build and install using pip - maturin is invoked automatically
${PYTHON} -m pip install . --no-deps --no-build-isolation -vv


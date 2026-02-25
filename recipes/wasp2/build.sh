#!/bin/bash
set -ex

# WASP2 Bioconda Build Script
# Handles Rust compilation via maturin for Python+Rust hybrid package

# Ensure cargo is available
export PATH="${CARGO_HOME}/bin:${PATH}"

# Bundle Rust crate licenses (Bioconda requirement)
# This collects licenses from all Rust dependencies
cargo-bundle-licenses \
    --format yaml \
    --output THIRDPARTY.yml \
    --manifest-path rust/Cargo.toml \
    --locked

# Set up environment for htslib linking
export HTSLIB_DIR="${PREFIX}"
export PKG_CONFIG_PATH="${PREFIX}/lib/pkgconfig:${PKG_CONFIG_PATH}"
export LD_LIBRARY_PATH="${PREFIX}/lib:${LD_LIBRARY_PATH}"
export LIBRARY_PATH="${PREFIX}/lib:${LIBRARY_PATH}"
export CPATH="${PREFIX}/include:${CPATH}"

# macOS-specific linker flags
if [[ "$OSTYPE" == "darwin"* ]]; then
    export RUSTFLAGS="-C link-arg=-undefined -C link-arg=dynamic_lookup"
fi

# Build the Rust extension with maturin
# The sdist from PyPI contains both Python and Rust source
maturin build \
    --release \
    --strip \
    --locked \
    --interpreter "${PYTHON}" \
    -m rust/Cargo.toml

# Install the built wheel
pip install target/wheels/*.whl --no-deps --no-build-isolation -vv

# Verify installation
python -c "import wasp2_rust; print('Rust extension loaded successfully')"
wasp2-count --help
wasp2-map --help
wasp2-analyze --help

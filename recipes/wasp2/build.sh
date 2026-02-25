#!/bin/bash
set -ex

# WASP2 Bioconda Build Script
# Handles Rust compilation via maturin for Python+Rust hybrid package

# Ensure cargo is available
export PATH="${CARGO_HOME}/bin:${PATH}"

# Bundle Rust crate licenses (Bioconda requirement)
# conda-forge cargo-bundle-licenses only supports --format and --output
# Must run from directory containing Cargo.toml
cd rust
cargo-bundle-licenses --format yaml --output ../THIRDPARTY.yml
cd ..

# Set LIBCLANG_PATH for bindgen (hts-sys generates FFI bindings via libclang)
export LIBCLANG_PATH="${BUILD_PREFIX}/lib"

# Set up environment for htslib linking
export HTSLIB_DIR="${PREFIX}"
export PKG_CONFIG_PATH="${PREFIX}/lib/pkgconfig:${PKG_CONFIG_PATH}"
export LD_LIBRARY_PATH="${PREFIX}/lib:${LD_LIBRARY_PATH}"
export LIBRARY_PATH="${PREFIX}/lib:${LIBRARY_PATH}"
export CPATH="${PREFIX}/include:${CPATH}"

# Set correct linker for conda-provided compiler
export CARGO_TARGET_X86_64_UNKNOWN_LINUX_GNU_LINKER="$CC"
export CARGO_TARGET_AARCH64_UNKNOWN_LINUX_GNU_LINKER="$CC"

# macOS-specific linker flags
if [[ "$OSTYPE" == "darwin"* ]]; then
    export RUSTFLAGS="-C link-arg=-undefined -C link-arg=dynamic_lookup"
fi

# Build the Rust extension with maturin
maturin build \
    --release \
    --strip \
    --interpreter "${PYTHON}" \
    -m rust/Cargo.toml

# Install the built wheel
"${PYTHON}" -m pip install target/wheels/*.whl --no-deps --no-build-isolation --no-cache-dir -vvv

# Verify installation
python -c "import wasp2_rust; print('Rust extension loaded successfully')"
wasp2-count --help
wasp2-map --help
wasp2-analyze --help

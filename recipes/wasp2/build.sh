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
# Pass conda compiler flags to bindgen's clang invocation (needed for ARM builds)
export BINDGEN_EXTRA_CLANG_ARGS="${CPPFLAGS} ${CFLAGS}"

# Set up environment for htslib linking
export HTSLIB_DIR="${PREFIX}"
export PKG_CONFIG_PATH="${PREFIX}/lib/pkgconfig:${PKG_CONFIG_PATH}"
export LD_LIBRARY_PATH="${PREFIX}/lib:${LD_LIBRARY_PATH}"
export LIBRARY_PATH="${PREFIX}/lib:${LIBRARY_PATH}"
export CPATH="${PREFIX}/include:${CPATH}"

# Set correct linker for conda-provided compiler
export CARGO_TARGET_X86_64_UNKNOWN_LINUX_GNU_LINKER="$CC"
export CARGO_TARGET_AARCH64_UNKNOWN_LINUX_GNU_LINKER="$CC"

# macOS-specific settings
if [[ "$OSTYPE" == "darwin"* ]]; then
    export RUSTFLAGS="-C link-arg=-undefined -C link-arg=dynamic_lookup"
    # Force deployment target for correct wheel platform tag.
    # The macosx_deployment_target conda packages set MACOSX_DEPLOYMENT_TARGET
    # to the runner OS version (e.g. 26.0), but pip rejects wheels tagged higher
    # than the actual running macOS. Hardcode like snapatac2/pybigtools recipes.
    # ARM64 macOS starts at 11.0; x86_64 uses 10.13.
    if [[ "$(uname -m)" == "arm64" ]]; then
        export MACOSX_DEPLOYMENT_TARGET=11.0
    else
        export MACOSX_DEPLOYMENT_TARGET=10.13
    fi
fi

# Workaround for conda-provided llvm-otool crashing on Rust .so files (SIGABRT).
# conda-build's post-processing calls otool -l on shared libs; the conda-forge
# cctools-port otool crashes on binaries with invalidated code signatures.
# Replace with system Xcode otool which handles this correctly.
# See: https://github.com/conda/conda-build/issues/4392#issuecomment-1370281802
if [[ "${target_platform:-}" == osx-* ]]; then
    for toolname in "otool" "install_name_tool"; do
        tool=$(find "${BUILD_PREFIX}/bin/" -name "*apple*-$toolname" 2>/dev/null)
        if [[ -n "$tool" ]]; then
            mv "${tool}" "${tool}.bak"
            ln -sf "/Library/Developer/CommandLineTools/usr/bin/${toolname}" "$tool"
        fi
    done
fi

# Build the Rust extension with maturin
maturin build \
    --release \
    --strip \
    --interpreter "${PYTHON}" \
    -m rust/Cargo.toml

# Install the built wheel
"${PYTHON}" -m pip install rust/target/wheels/*.whl --no-deps --no-build-isolation --no-cache-dir -vvv

# Verify the Rust extension loads (no runtime deps needed for this check)
python -c "import wasp2_rust; print('Rust extension loaded successfully')"

#!/bin/bash -e

# Build with Rust
cargo build --release

# Install the binaries
cargo install --verbose --path kmertools --root "${PREFIX}" 

# Check if the system is macOS
if [[ "$(uname)" == "Darwin" ]]; then
    # Get the architecture
    arch=$(uname -m)
    
    # Set MACOSX_DEPLOYMENT_TARGET based on architecture
    if [[ "$arch" == "x86_64" ]]; then
        # For Intel Macs
        export MACOSX_DEPLOYMENT_TARGET=10.12
    elif [[ "$arch" == "arm64" ]]; then
        # For Apple Silicon Macs
        export MACOSX_DEPLOYMENT_TARGET=11.0
    else
        echo "Unknown architecture: $arch"
        exit 1
    fi
    
    echo "Set MACOSX_DEPLOYMENT_TARGET to $MACOSX_DEPLOYMENT_TARGET for $arch"
else
    echo "Not running on macOS, skipping MACOSX_DEPLOYMENT_TARGET"
fi

# Build statically linked binary with Rust
RUST_BACKTRACE=1
# Build with maturin
maturin build -m ./conda/Cargo.toml -b pyo3 --interpreter "${PYTHON}" --release --strip

# Install the wheel file
${PYTHON} -m pip install ./target/wheels/*.whl --no-deps --no-build-isolation --no-cache-dir -vvv

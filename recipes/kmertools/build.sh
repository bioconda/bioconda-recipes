#!/bin/bash -e

# Build with Rust
cargo build --release

# Install the binaries
cargo install --path kmertools --root $PREFIX 

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

# Build with maturin
maturin build --release --find-interpreter --manifest-path ./pykmertools/Cargo.toml

# Install the wheel file
pip install ./target/wheels/*.whl 

#!/bin/bash -e

# Build with Rust
cargo build --release

# Install the binaries
cargo install --path kmertools --root $PREFIX 

# Build with maturin
maturin build --release --find-interpreter --manifest-path ./pykmertools/Cargo.toml

# Install the wheel file
pip install ./target/wheels/*.whl 

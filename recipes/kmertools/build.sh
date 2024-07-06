#!/bin/bash -e

# Build with Rust
cargo build --release

# Install the binaries
cargo install --manifest-path kmertools/Cargo.toml --root $PREFIX 

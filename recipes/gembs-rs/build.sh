#!/bin/bash
set -euxo pipefail

# Install Rust if not already installed
if ! command -v rustc &> /dev/null
then
    curl https://sh.rustup.rs -sSf | sh -s -- -y
    source $HOME/.cargo/env
    rustup update
fi

# Build and install gemBS
cargo build --release
mkdir -p $PREFIX/bin
cp target/release/gemBS $PREFIX/bin/

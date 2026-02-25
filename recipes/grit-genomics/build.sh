#!/bin/bash
set -ex

# Build the release binary
cargo build --release

# Install the binary
mkdir -p $PREFIX/bin
cp target/release/grit $PREFIX/bin/

#!/bin/bash
set -ex

# Build rastair using cargo
cargo build --release

# Install the binary to $PREFIX/bin
install -Dm755 target/release/rastair "$PREFIX/bin/rastair"

mkdir -p $PREFIX/share/rastair/scripts
cp -R scripts/* $PREFIX/share/rastair/scripts/

#!/bin/bash
set -ex

# Build rastair using cargo
cargo install -v --locked --no-track --root $PREFIX --path .

# Copy R scripts
mkdir -p $PREFIX/share/rastair/scripts
cp -R scripts/* $PREFIX/share/rastair/scripts/

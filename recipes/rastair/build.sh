#!/bin/bash
set -ex

cargo-bundle-licenses --format yaml --output THIRDPARTY.yml
cargo install -v --locked --no-track --root $PREFIX --path .

# Copy R scripts
mkdir -p $PREFIX/share/rastair/scripts
cp -R scripts/* $PREFIX/share/rastair/scripts/

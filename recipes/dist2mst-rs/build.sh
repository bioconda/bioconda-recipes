#!/bin/bash
set -ex

# Build and install
cargo install --no-track --locked --root "$PREFIX" --path .

# Bundle third-party licenses
cargo-bundle-licenses --format yaml --output THIRDPARTY.yml

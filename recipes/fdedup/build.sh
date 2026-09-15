#!/bin/bash

# Bundle all dependency licenses
cargo-bundle-licenses --format yaml --output THIRDPARTY.yml

# Install the binary (Bioconda requires --no-track)
cargo install --no-track --locked --root "$PREFIX" --path .
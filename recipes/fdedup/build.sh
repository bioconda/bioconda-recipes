#!/bin/bash

# Bundle all dependency licenses
cargo-bundle-licenses --format yaml --output THIRDPARTY.yml

# Install the binary
cargo install --locked --root "$PREFIX" --path .

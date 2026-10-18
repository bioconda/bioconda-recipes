#!/bin/bash

set -ex

# Bundle licenses for all Rust dependencies
cargo-bundle-licenses --format yaml --output THIRDPARTY.yml

# Install using recommended flags for reproducibility
cargo install \
    --verbose \
    --locked \
    --no-track \
    --root "${PREFIX}" \
    --path .


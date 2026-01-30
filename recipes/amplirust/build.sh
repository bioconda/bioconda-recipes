#!/bin/bash
set -ex

# Build with cargo
RUST_BACKTRACE=1 cargo install --no-track --locked --root "${PREFIX}" --path .

# Bundle third-party licenses
cargo-bundle-licenses --format yaml --output THIRDPARTY.yml

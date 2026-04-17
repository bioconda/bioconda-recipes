#!/bin/bash -euo

cargo-bundle-licenses --format yaml --output THIRDPARTY.yml

# build statically linked binary with Rust
RUST_BACKTRACE=1
cargo install --verbose --path . --no-track --root "${PREFIX}"

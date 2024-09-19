#!/bin/bash -euo

set -xe

# build statically linked binary with Rust
cargo-bundle-licenses --format yaml --output THIRDPARTY.yml
RUST_BACKTRACE=1 cargo install --verbose --locked --root $PREFIX --path .
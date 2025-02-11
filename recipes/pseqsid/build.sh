#!/bin/bash -euo

set -xe

cargo-bundle-licenses --format yaml --output THIRDPARTY.yml
# Build statically linked binary with Rust
RUST_BACKTRACE=1 cargo install -v --locked --no-track --root $PREFIX --path .

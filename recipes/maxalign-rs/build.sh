#!/usr/bin/env bash
set -xue -o pipefail

# build statically linked binary with Rust
cargo-bundle-licenses --format yaml --output THIRDPARTY.yml
RUST_BACKTRACE=1 cargo install --verbose --locked --no-track --root $PREFIX --path .
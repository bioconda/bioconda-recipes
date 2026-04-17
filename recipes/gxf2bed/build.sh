#!/bin/bash
set -xe

# bundle licenses
cargo-bundle-licenses --format yaml --output THIRDPARTY.yml
# build statically linked binary with Rust
RUST_BACKTRACE=1 cargo install --verbose --locked --path . --root ${PREFIX} --no-track

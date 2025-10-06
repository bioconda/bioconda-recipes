#!/bin/bash 

set -xeuo

cargo-bundle-licenses --format yaml --output ../THIRDPARTY.yml


# build statically linked binary with Rust:
RUST_BACKTRACE=1 
cargo install --no-track --verbose --root "${PREFIX}" --path . --all-features


#!/bin/bash -euo

set -xe

# Export compiler environment variables for AGC makefile
export CC="${CC:-gcc}"
export CXX="${CXX:-g++}"

cargo-bundle-licenses --format yaml --output THIRDPARTY.yml

# build statically linked binary with Rust
RUST_BACKTRACE=1
cargo install -v --no-track --path . --root "${PREFIX}"

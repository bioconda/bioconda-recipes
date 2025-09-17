#!/bin/bash -euo

mkdir -p ${PREFIX}/bin

# Build statically linked binary with Rust
export C_INCLUDE_PATH="${PREFIX}/include" \
export LIBRARY_PATH="${PREFIX}/lib" \

# build statically linked binary with Rust
RUST_BACKTRACE=1
cargo install --verbose --path . --root ${PREFIX}

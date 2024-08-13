#!/bin/bash
set -ex

# build statically linked binary with Rust
export LD="${CC}" C_INCLUDE_PATH="${PREFIX}/include" LIBRARY_PATH="${PREFIX}/lib"
RUST_BACKTRACE=1
cargo install --path . --root "${PREFIX}" --verbose

#!/bin/bash -euo

export LIBRARY_PATH="${PREFIX}/lib"
export INCLUDE_PATH="${PREFIX}/include"
export LDFLAGS="${LDFLAGS} -L${PREFIX}/lib"
export CXXFLAGS="${CXXFLAGS} -O3 -I${PREFIX}/include"

# build statically linked binary with Rust
RUST_BACKTRACE=1
cargo install --verbose --no-track --path . --root "${PREFIX}"

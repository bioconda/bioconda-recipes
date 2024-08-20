#!/bin/bash -euo
export CFLAGS="${CFLAGS} -O3 -fcommon"
export CXXFLAGS="${CFLAGS} -O3 -fcommon -I${PREFIX}/include"

# build statically linked binary with Rust
RUST_BACKTRACE=1 cargo install --verbose --root "${PREFIX}" --path .

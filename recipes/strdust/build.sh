#!/bin/bash -euo

export INCLUDE_PATH="${PREFIX}/include"
export LDFLAGS="${LDFLAGS} -L${PREFIX}/lib"
export CFLAGS="${CFLAGS} -O3 -fcommon"
export CXXFLAGS="${CFLAGS} -O3 -fcommon -I${PREFIX}/include"

# build statically linked binary with Rust
RUST_BACKTRACE=1 cargo install --verbose --root "${PREFIX}" --path .

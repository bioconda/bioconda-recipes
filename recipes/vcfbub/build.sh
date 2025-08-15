#!/bin/bash -euo

mkdir -p $PREFIX/bin

export INCLUDE_PATH="${PREFIX}/include"
export LDFLAGS="${LDFLAGS} -L${PREFIX}/lib"
export CPPFLAGS="${CPPFLAGS} -I${PREFIX}/include"
export CFLAGS="${CFLAGS} -O3 -Wno-implicit-function-declaration"

RUST_BACKTRACE=1
cargo install --verbose --no-track --path . --root "${PREFIX}"

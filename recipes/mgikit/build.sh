#!/bin/bash -e

export LDFLAGS="${LDFLAGS} -L${PREFIX}/lib"
export CFLAGS="${CFLAGS} -O3 -Wno-implicit-function-declaration"

RUST_BACKTRACE=1
cargo install --no-track --verbose --root "${PREFIX}" --path .

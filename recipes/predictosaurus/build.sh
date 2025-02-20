#!/bin/bash -e

export CFLAGS="${CFLAGS} -O3 -fno-rtti"
export CPPFLAGS="${CPPFLAGS} -I${PREFIX}/include"
export LDFLAGS="${LDFLAGS} -L${PREFIX}/lib"

export BINDGEN_EXTRA_CLANG_ARGS="${CFLAGS} ${CPPFLAGS} ${LDFLAGS}"

RUST_BACKTRACE=1
cargo install --no-track --locked --verbose --root "${PREFIX}" --path .

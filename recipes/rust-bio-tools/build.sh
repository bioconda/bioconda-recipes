#!/bin/bash -e

export BINDGEN_EXTRA_CLANG_ARGS="${CFLAGS} ${CPPFLAGS} ${LDFLAGS}"

RUST_BACKTRACE=1
cargo install --no-track --verbose --root "${PREFIX}" --path .

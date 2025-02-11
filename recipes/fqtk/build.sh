#!/bin/bash -e

export BINDGEN_EXTRA_CLANG_ARGS="${CFLAGS} ${CPPFLAGS} ${LDFLAGS}"

# build statically linked binary with Rust
RUST_BACKTRACE=1
cargo install --no-track --verbose --root "${PREFIX}" --path .

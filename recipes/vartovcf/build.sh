#!/bin/bash -e

export BINDGEN_EXTRA_CLANG_ARGS="${CFLAGS} ${CPPFLAGS} ${LDFLAGS}"
export LIBCLANG_PATH="${BUILD_PREFIX}/lib"

RUST_BACKTRACE=1

export CFLAGS="${CFLAGS} -Wno-implicit-function-declaration"

cargo-bundle-licenses --format yaml --output THIRD

cargo install --no-track --locked --verbose --root "${PREFIX}" --path .

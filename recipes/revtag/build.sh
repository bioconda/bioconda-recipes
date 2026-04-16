#!/bin/bash -e

export BINDGEN_EXTRA_CLANG_ARGS="${CFLAGS} ${CPPFLAGS} ${LDFLAGS}"

RUST_BACKTRACE=1

export CFLAGS="${CFLAGS} -Wno-implicit-function-declaration"

cargo-bundle-licenses --format yaml --output THIRD

cargo install --no-track --verbose --root "${PREFIX}" --path .

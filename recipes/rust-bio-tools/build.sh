#!/bin/bash -e

export BINDGEN_EXTRA_CLANG_ARGS="${CFLAGS} ${CPPFLAGS} ${LDFLAGS}"

cargo install --no-track --locked --verbose --root "${PREFIX}" --path .

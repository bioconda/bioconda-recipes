#!/bin/bash -eu

# Make sure bindgen passes on our compiler flags.
export BINDGEN_EXTRA_CLANG_ARGS="${CPPFLAGS} ${CFLAGS} ${LDFLAGS}"

cargo install --no-track --locked --verbose --root "${PREFIX}" --path .

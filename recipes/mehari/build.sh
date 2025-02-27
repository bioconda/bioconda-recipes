#!/bin/bash -xeuo

# Make sure bindgen passes on our compiler flags.
export BINDGEN_EXTRA_CLANG_ARGS="${CPPFLAGS} ${CFLAGS} ${LDFLAGS}"

export ROCKSDB_LIB_DIR="${PREFIX}/lib/"
export SNAPPY_LIB_DIR="${PREFIX}/lib/"

cargo install --no-track --locked --root "${PREFIX}" --path .

#!/bin/bash -xeuo

# Make sure bindgen passes on our compiler flags.
export BINDGEN_EXTRA_CLANG_ARGS="${CPPFLAGS} ${CFLAGS} ${LDFLAGS}"
echo "BINDGEN_EXTRA_CLANG_ARGS=${BINDGEN_EXTRA_CLANG_ARGS}"

export ROCKSDB_LIB_DIR="${PREFIX}/lib/"
export SNAPPY_LIB_DIR="${PREFIX}/lib/"
echo "ROCKSDB_LIB_DIR=${ROCKSDB_LIB_DIR}"

cargo install --no-track --locked --root "${PREFIX}" --path .

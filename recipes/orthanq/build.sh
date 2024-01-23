#!/bin/bash -eu

# Make sure bindgen passes on our compiler flags.
export BINDGEN_EXTRA_CLANG_ARGS="${CPPFLAGS} ${CFLAGS} ${LDFLAGS}"
export HDF5_DIR=${PREFIX}
export RUSTFLAGS="-C link-args=-Wl,-rpath,$HDF5_DIR/lib"

cargo install --no-track --locked --verbose --root "${PREFIX}" --path .

#!/bin/bash -eu

export LDFLAGS="${LDFLAGS} -L${PREFIX}/lib"
export CPPFLAGS="${CPPFLAGS} -I${PREFIX}/include"
export CFLAGS="${CFLAGS} -O3 -Wno-implicit-function-declaration"
# Make sure bindgen passes on our compiler flags.
export BINDGEN_EXTRA_CLANG_ARGS="${CPPFLAGS} ${CFLAGS} ${LDFLAGS}"
export HDF5_DIR="${PREFIX}"
export RUSTFLAGS="-C link-args=-Wl,-rpath,$HDF5_DIR/lib"
export PYO3_PYTHON="${PYTHON}"

cargo-bundle-licenses --format yaml --output THIRDPARTY.yml

RUST_BACKTRACE=1
cargo install --no-track --locked --verbose --root "${PREFIX}" --path .

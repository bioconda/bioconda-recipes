#!/bin/bash

set -ex

export BINDGEN_EXTRA_CLANG_ARGS="$CFLAGS"
export LIBCLANG_PATH=$BUILD_PREFIX/lib/libclang${SHLIB_EXT}

maturin build --release --strip --manylinux off --interpreter="${PYTHON}" -m Cargo.toml

${PYTHON} -m pip install . --ignore-installed --no-cache-dir -vvv

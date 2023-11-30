#!/bin/bash

echo "Installing pyo3-branchwater via pip..."

set -ex

export BINDGEN_EXTRA_CLANG_ARGS="$CFLAGS"
export LIBCLANG_PATH=$BUILD_PREFIX/lib/libclang${SHLIB_EXT}

"${PREFIX}/bin/pip" install pyo3-branchwater==0.8.1

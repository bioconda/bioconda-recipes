#!/bin/bash

set -ex

export BINDGEN_EXTRA_CLANG_ARGS="$CFLAGS"
export LIBCLANG_PATH=$BUILD_PREFIX/lib/libclang${SHLIB_EXT}



${PYTHON} -m pip install . --ignore-installed --no-cache-dir -vvv

#!/bin/bash

set -e
set -x

if [ "$(uname)" = "Darwin" ]; then
  # LDFLAGS fix: https://github.com/AnacondaRecipes/intel_repack-feedstock/issues/8
  export LDFLAGS="${LDFLAGS} -Wl,-pie -Wl,-headerpad_max_install_names -Wl,-rpath,$PREFIX/lib -L$PREFIX/lib"
else
  export LDFLAGS="${LDFLAGS} -L$PREFIX/lib"
  export MKL_THREADING_LAYER="GNU"
fi

# https://bioconda.github.io/contributor/troubleshooting.html#zlib-errors
export CFLAGS="${CFLAGS} -O3 -I$PREFIX/include"
export INCLUDE_PATH="${PREFIX}/include"

cmake -S . -B build \
  -DCMAKE_INSTALL_PREFIX:PATH=${PREFIX} \
  -DCMAKE_BUILD_TYPE="Release"

cmake --build build --target install -j "${CPU_COUNT}" -v

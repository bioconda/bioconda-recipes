#!/bin/bash

set -e
set -x

if [ "$(uname)" = "Darwin" ]; then
  # LDFLAGS fix: https://github.com/AnacondaRecipes/intel_repack-feedstock/issues/8
  export LDFLAGS="-Wl,-pie -Wl,-headerpad_max_install_names -Wl,-rpath,$PREFIX/lib -L$PREFIX/lib"
fi
export MKL_THREADING_LAYER="GNU"

mkdir -p build
cd build

cmake \
  -DBUILD_SHARED_LIBS:BOOL=ON \
  -DCMAKE_PREFIX_PATH:PATH=${PREFIX} \
  -DCMAKE_INSTALL_PREFIX:PATH=${PREFIX} \
  -DCMAKE_INSTALL_LIBDIR=lib \
  -DCMAKE_BUILD_TYPE="Release" \
  -S "${SRC_DIR}"

make -j${CPU_COUNT:=1} regenie
make install
cd ..

# bash test/test_conda.sh --path "${SRC_DIR}" --gz

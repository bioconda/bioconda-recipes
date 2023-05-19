#!/bin/bash

export C_INCLUDE_PATH=${PREFIX}/include
export LIBRARY_PATH=${PREFIX}/lib

python setup.py install --single-version-externally-managed --record=record.txt

mkdir hapog_build && cd hapog_build
export HTSLIB_ROOT=${LIBRARY_PATH}
CMAKE_PLATFORM_FLAGS+=(-DCMAKE_TOOLCHAIN_FILE="${RECIPE_DIR}/cross-linux.cmake")
cmake -DCMAKE_INSTALL_PREFIX=${PREFIX} \
  ${CMAKE_PLATFORM_FLAGS[@]} \
  ../src
make
cd ..
cp -r hapog_build/hapog ${PREFIX}/bin/hapog_bin

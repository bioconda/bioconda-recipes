#!/bin/bash

set -euxo pipefail

mkdir conda_build
pushd conda_build

CLP_ROOT=${PREFIX} \
ARMADILLO_ROOT=${BUILD_PREFIX} \
CXXFLAGS="-I${BUILD_PREFIX}/include $CXXFLAGS" \
CMAKE_PREFIX_PATH=${BUILD_PREFIX} \
cmake -DCMAKE_BUILD_TYPE=Release \
      -DCMAKE_INSTALL_PREFIX=${PREFIX} \
      ..

make -j${CPU_COUNT}
make install
make clean

popd

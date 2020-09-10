#!/bin/bash
set -eu -o pipefail

mkdir -p $PREFIX/bin
mkdir -p $PREFIX/lib

mkdir -p build
cd build
cmake -DCMAKE_BUILD_TYPE=RELEASE \
      -DCONDA_BUILD=TRUE \
      -DBoost_NO_BOOST_CMAKE=ON \
      -DCMAKE_OSX_DEPLOYMENT_TARGET=10.9 \
      -DCMAKE_INSTALL_PREFIX:PATH=$PREFIX \
      -DBoost_NO_SYSTEM_PATHS=ON \
      ..
make VERBOSE=1

cp src/cobs $PREFIX/bin

echo "cmake-powered unit test"
CTEST_OUTPUT_ON_FAILURE=1 make test

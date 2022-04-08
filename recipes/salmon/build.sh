#!/bin/bash
set -eu -o pipefail

mkdir -p $PREFIX/bin
mkdir -p $PREFIX/lib

mkdir -p build
cd build
cmake -DCMAKE_BUILD_TYPE=RELEASE \
      -DCONDA_BUILD=TRUE \
      -DBoost_NO_BOOST_CMAKE=ON \
      -DCMAKE_OSX_DEPLOYMENT_TARGET=10.11 \
      -DCMAKE_INSTALL_PREFIX:PATH=$PREFIX \
      -DBoost_NO_SYSTEM_PATHS=ON \
      -DNO_IPO=TRUE \
      ..
make VERBOSE=1
echo "unit test executable"
./src/unitTests
echo "installing"
make install CFLAGS="-L${PREFIX}/lib -I${PREFIX}/include"
../tests/unitTests
echo "cmake-powered unit test"
CTEST_OUTPUT_ON_FAILURE=1 make test


#!/bin/bash
set -eu -o pipefail

mkdir -p $PREFIX/bin
mkdir -p $PREFIX/lib

mkdir -p build
cd build
# Patch CMake file to enable compiling with boost 1.70
sed -i.bak 's/"1.66"/"1.70"/' CMakeLists.txt

cmake -DCMAKE_BUILD_TYPE=RELEASE -DCONDA_BUILD=TRUE -DCMAKE_OSX_DEPLOYMENT_TARGET=10.9 -DCMAKE_INSTALL_PREFIX:PATH=$PREFIX -DBOOST_ROOT=$PREFIX -DBoost_NO_SYSTEM_PATHS=ON ..
make
echo "unit test executable"
./src/unitTests
echo "installing"
make install CFLAGS="-L${PREFIX}/lib -I${PREFIX}/include"
../tests/unitTests
echo "cmake-powered unit test"
CTEST_OUTPUT_ON_FAILURE=1 make test


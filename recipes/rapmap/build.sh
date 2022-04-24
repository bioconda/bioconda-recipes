#!/bin/bash
set -eu -o pipefail

mkdir build && cd build
cmake -DNO_NATIVE_ARCH=TRUE -DCMAKE_CXX_FLAGS=-mno-avx -DCMAKE_OSX_DEPLOYMENT_TARGET=10.9 -DCMAKE_INSTALL_PREFIX:PATH=$PREFIX -DCMAKE_BUILD_TYPE=RELEASE ..
make
make install
CTEST_OUTPUT_ON_FAILURE=1 make test

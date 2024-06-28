#!/bin/bash
set -exu -o pipefail

case $(uname -m) in
    x86_64)
        ARCH_FLAGS="-mno-avx"
        ;;
    *)
        ARCH_FLAGS=""
        ;;
esac

mkdir build && cd build
cmake -DNO_NATIVE_ARCH=TRUE -DCMAKE_CXX_FLAGS="${CXXFLAGS} ${ARCH_FLAGS}" -DCMAKE_OSX_DEPLOYMENT_TARGET=10.9 -DCMAKE_INSTALL_PREFIX:PATH=$PREFIX -DCMAKE_BUILD_TYPE=RELEASE ..
make -j ${CPU_COUNT}
make install
CTEST_OUTPUT_ON_FAILURE=1 make test

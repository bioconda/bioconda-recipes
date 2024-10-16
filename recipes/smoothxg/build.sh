#!/bin/bash

set -xe

export LIBRARY_PATH=${PREFIX}/lib
export LD_LIBRARY_PATH=${PREFIX}/lib
export CPATH=${PREFIX}/include
export C_INCLUDE_PATH=${PREFIX}/include
export CPLUS_INCLUDE_PATH=${PREFIX}/include
export CPP_INCLUDE_PATH=${PREFIX}/include
export CXX_INCLUDE_PATH=${PREFIX}/include

case $(uname -m) in
    aarch64 | arm64)
        ARCH_FLAGS=""
        sed -i 's/-msse4.1/-Ofast/g' deps/spoa/CMakeLists.txt
        ;;
    *)
        ARCH_FLAGS="-march=sandybridge"
        sed -i 's/-msse4.1/-march=sandybridge -Ofast/g' deps/spoa/CMakeLists.txt
        sed -i 's/-march=native/-march=sandybridge -Ofast/g' deps/spoa/CMakeLists.txt
        sed -i 's/-march=native/-march=sandybridge -Ofast/g' deps/abPOA/CMakeLists.txt
        ;;
esac

cmake -H. -Bbuild -DCMAKE_BUILD_TYPE=Generic -DEXTRA_FLAGS="${ARCH_FLAGS} -Ofast"
cmake --build build --verbose -j"${CPU_COUNT}"
mkdir -p $PREFIX/bin
mv bin/* $PREFIX/bin

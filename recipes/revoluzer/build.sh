#!/bin/bash
CXXFLAGS="-I${BUILD_PREFIX}/include $CXXFLAGS"


cmake -DCMAKE_VERBOSE_MAKEFILE:BOOL=ON -H. -Bbuild -DCMAKE_BUILD_TYPE=Generic -DEXTRA_FLAGS='-march=sandybridge -Ofast'
cmake --build build
mkdir -p $PREFIX/bin
echo "installing: $(find build/src -type f -executable)"
mv $(find build/src -type f -executable) $PREFIX/bin

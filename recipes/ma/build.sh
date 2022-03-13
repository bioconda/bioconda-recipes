#!/bin/bash

mkdir -p build
cd build
cmake -DCMAKE_BUILD_TYPE=RELEASE -DWITH_DB=OFF -DCMAKE_INSTALL_PREFIX=${PREFIX} -DCMAKE_EXE_LINKER_FLAGS=-L${PREFIX}/lib ..
make VERBOSE=1 -j 8 maCMD

find . -name maCMD -ls
mkdir -p $PREFIX/bin
mkdir -p $PREFIX/lib
cp build/maCMD $PREFIX/bin
cp build/lib*.so $PREFIX/lib/

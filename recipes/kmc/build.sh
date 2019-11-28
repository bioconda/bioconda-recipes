#!/bin/bash
set -x -e -o pipefail

export CPPFLAGS="-I${PREFIX}/include"
export LDFLAGS="-L${PREFIX}/lib"
export CXXFLAGS="${CXXFLAGS}"

make CC=${CXX} CFLAGS=${CPPFLAGS}
make CC=${CXX} CFLAGS=${CPPFLAGS} kmc_api/libkmc.so

mkdir -p $PREFIX/bin
mkdir -p $PREFIX/lib
mkdir -p $PREFIX/include

mv bin/kmc $PREFIX/bin/kmc
mv bin/kmc_tools $PREFIX/bin
mv bin/kmc_dump $PREFIX/bin
mv kmc_api/*.so $PREFIX/lib
mv kmc_api/*.h $PREFIX/include

#!/bin/bash
export CFLAGS="$CFLAGS -I$PREFIX/include"
export LDFLAGS="$LDFLAGS -L$PREFIX/lib"

mkdir -p $PREFIX/bin/

make CC=${CC} CXX=${CXX} CFLAGS="${CFLAGS} -L${PREFIX}/lib -fcommon" CXXFLAGS="${CXXFLAGS} -fcommon -L${PREFIX}/lib" LDFLAGS="${LDFLAGS}"
cp kssd $PREFIX/bin/

#!/bin/bash

mkdir -p $PREFIX/bin

export LDFLAGS="${LDFLAGS} -L${PREFIX}/lib"
export CPPFLAGS="${CPPFLAGS} -I${PREFIX}/include"
export CXXFLAGS="${CXXFLAGS} -O3"

cd source
make CC="${CXX}" FLAGS="${CPPFLAGS} ${CXXFLAGS}" -j "${CPU_COUNT}"

cp -f readal $PREFIX/bin
cp -f statal $PREFIX/bin
cp -f trimal $PREFIX/bin

chmod 0755 $PREFIX/bin/readal
chmod 0755 $PREFIX/bin/statal
chmod 0755 $PREFIX/bin/trimal

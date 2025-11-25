#!/bin/bash

export LDFLAGS="${LDFLAGS} -L${PREFIX}/lib"
export CPPFLAGS="${CPPFLAGS} -I${PREFIX}/include"
export CFLAGS="${CFLAGS} -O3"
export CXXFLAGS="${CXXFLAGS} -O3"

make -C Misc/Applications/pKiss all PREFIX="$PREFIX" CC="$CC" CXX="${CXX}" -j"${CPU_COUNT}"

make -C Misc/Applications/pKiss install-program PREFIX="$PREFIX" CC="$CC"

make -C Misc/Applications/lib install PREFIX="$PREFIX" CC="$CC"

chmod +x $PREFIX/bin/pKiss* $PREFIX/bin/addRNA*

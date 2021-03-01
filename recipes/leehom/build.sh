#!/bin/bash

export CFLAGS="$CFLAGS -I$PREFIX/include"
export LDFLAGS="$LDFLAGS -L$PREFIX/lib"

make  CXX="${CXX}" LIBGABINC=${PREFIX}/include/libgab/ LIBGABLIB=${PREFIX}/lib/libgab/ BAMTOOLSINC=${PREFIX}/include/bamtools/ BAMTOOLSLIB=${PREFIX}/lib/ all
cp src/leeHom ${PREFIX}/bin/
cd ..


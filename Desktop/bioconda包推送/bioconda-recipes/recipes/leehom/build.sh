#!/bin/bash

export CFLAGS="$CFLAGS -I$PREFIX/include"
export LDFLAGS="$LDFLAGS -L$PREFIX/lib"

cd src/
make  CXX="${CXX}" LIBGABINC=${PREFIX}/include/libgab/ LIBGABLIB=${PREFIX}/lib/libgab/ BAMTOOLSINC=${PREFIX}/include/bamtools/ BAMTOOLSLIB=${PREFIX}/lib/ all
cp leeHom ${PREFIX}/bin/
cd ..


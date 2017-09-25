#!/bin/bash
export C_INCLUDE_PATH=$PREFIX/include
make OPTS="-Wall -O3" HTSLIB="-lhts" INCLUDE_DIRS="-I${PREFIX}/include" LIB_DIRS="-L${PREFIX}/lib"
make install prefix="${PREFIX}/bin"

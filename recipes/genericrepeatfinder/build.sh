#!/bin/sh
set -x -e

export CFLAGS="-I$PREFIX/include"
export CPPFLAGS="-I$PREFIX/include"
export CXXFLAGS="-I$PREFIX/include"
export LDFLAGS="-L$PREFIX/lib"
export CPATH=${PREFIX}/include
export C_INCLUDE_PATH=${C_INCLUDE_PATH}:${PREFIX}/include
export LIBRARY_PATH="${PREFIX}/lib"
export LD_LIBRARY_PATH="${PREFIX}/lib"

cd src
make CC=$CXX

mkdir -p ${PREFIX}/bin
cp grf-alignment/grf-alignment ${PREFIX}/bin/
cp grf-alignment2/grf-alignment2 ${PREFIX}/bin/
cp grf-dbn/grf-dbn ${PREFIX}/bin/
cp grf-filter/grf-filter ${PREFIX}/bin/
cp grf-intersperse/grf-intersperse ${PREFIX}/bin/
cp grf-main/grf-main ${PREFIX}/bin/
cp grf-mite-cluster/grf-mite-cluster ${PREFIX}/bin/
cp grf-nest/grf-nest ${PREFIX}/bin/

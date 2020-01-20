#!/bin/sh
set -x -e

export C_INCLUDE_PATH=${PREFIX}/include

cd src

if [[ "$OSTYPE" == "darwin"* ]]; then
  make CC=clang++
else
  make CC=$GXX
fi

mkdir -p ${PREFIX}/bin
cp grf-alignment/grf-alignment ${PREFIX}/bin/
cp grf-alignment2/grf-alignment2 ${PREFIX}/bin/
cp grf-dbn/grf-dbn ${PREFIX}/bin/
cp grf-filter/grf-filter ${PREFIX}/bin/
cp grf-intersperse/grf-intersperse ${PREFIX}/bin/
cp grf-main/grf-main ${PREFIX}/bin/
cp grf-mite-cluster/grf-mite-cluster ${PREFIX}/bin/
cp grf-nest/grf-nest ${PREFIX}/bin/

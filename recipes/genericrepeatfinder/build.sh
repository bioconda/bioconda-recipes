#!/bin/sh
set -x -e

cd src
make CC=$GXX

mkdir -p ${PREFIX}/bin
cp grf-alignment/grf-alignment ${PREFIX}/bin/
cp grf-alignment2/grf-alignment2 ${PREFIX}/bin/
cp grf-dbn/grf-dbn ${PREFIX}/bin/
cp grf-filter/grf-filter ${PREFIX}/bin/
cp grf-intersperse/grf-intersperse ${PREFIX}/bin/
cp grf-main/grf-main ${PREFIX}/bin/
cp grf-mite-cluster/grf-mite-cluster ${PREFIX}/bin/
cp grf-nest/grf-nest ${PREFIX}/bin/

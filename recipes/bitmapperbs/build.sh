#!/bin/bash
chmod +x htslib/version.sh

make -f ${RECIPE_DIR}/newMakefile PREFIX=${PREFIX} CC=${CC} CXX=${CXX}

mkdir -p ${PREFIX}/bin
mv bitmapperBS ${PREFIX}/bin/
mkdir -p ${PREFIX}/lib
mv htslib_aim/lib/libhtsBit* ${PREFIX}/lib/
mv htslib_aim/lib/libhts.so.2to3part2 ${PREFIX}/lib/

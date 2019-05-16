#!/bin/bash
chmod +x htslib/version.sh

make -f ${RECIPE_DIR}/newMakefile PREFIX=${PREFIX} CC=${CC} CXX=${CXX}

mkdir -p ${PREFIX}/bin
mv bitmapperBS ${PREFIX}/bin/
mkdir -p ${PREFIX}/lib
ls htslib_aim/lib
mv htslib_aim/lib/libhtsBit* ${PREFIX}/lib/
ls ${PREFIX}/lib

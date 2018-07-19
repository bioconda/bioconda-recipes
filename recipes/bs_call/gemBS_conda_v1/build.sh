#!/bin/bash

export CPATH=${PREFIX}/include

sed -i.bak '
    /^INCLUDE_FLAGS=/ s@$@ -I'$PREFIX'/include@
    /^LIB_PATH_FLAGS=/ s@$@ -L'$PREFIX'/lib@
  ' GEMTools/Makefile.mk.in

sed -i.bak '
    /^BS_CALL_INCLUDE_FLAGS=/ s@$@ -I'$PREFIX'/include@
    /^BS_CALL_LIB_PATH_FLAGS=/ s@$@ -L'$PREFIX'/lib@
    /^DBSNP_INCLUDE_FLAGS=/ s@$@ -I'$PREFIX'/include@
    /^DBSNP_LIB_PATH_FLAGS=/ s@$@ -L'$PREFIX'/lib@
  ' src/Makefile.mk.in


if [[ "$OSTYPE" == "darwin"* ]]; then
  #remove openmp for macos
  sed -i.bak 's/-fopenmp/-Xpreprocessor -fopenmp -lomp/g' src/Makefile
  sed -i.bak 's/-fopenmp/-Xpreprocessor -fopenmp -lomp/g' GEMTools/src/Makefile
  sed -i.bak 's/-fopenmp/-Xpreprocessor -fopenmp -lomp/g' GEMTools/tools/Makefile
  sed -i.bak 's/-fopenmp/-Xpreprocessor -fopenmp -lomp/g' GEMTools/test/Makefile
fi


./configure

make all
mkdir -p $PREFIX/bin
cp bin/bs_call $PREFIX/bin
cp bin/dbSNP_idx $PREFIX/bin

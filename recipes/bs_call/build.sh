#!/bin/bash

export CPATH=${PREFIX}/include

#This version of bs_call lacks a functioning configure script.
#  Make sure all dependencies are found (including bzip2 and zlib)
sed -i.bak '
    /^GSL_LIB = -L\/apps\/GSL\/2.4\/lib\// s@= -L.*@= -L'$PREFIX'/lib@
    /^GSL_INC = -I\/apps\/GSL\/2.4\/include\// s@= -I.*@= -I'$PREFIX'/include@
  ' Gsl.mk

sed -i.bak '
    /^INCLUDE_FLAGS=/ s@$@ -I'$PREFIX'/include@
    /^LIB_PATH_FLAGS=/ s@$@ -L'$PREFIX'/lib@
  ' GEMTools/Makefile.mk

if [[ "$OSTYPE" == "darwin"* ]]; then
  #openmp cannot be disabled. This is a workaround based on:
  #https://iscinumpy.gitlab.io/post/omp-on-high-sierra/
  sed -i.bak 's/-fopenmp/-Xpreprocessor -fopenmp -lomp/g' src/Makefile
  sed -i.bak 's/-fopenmp/-Xpreprocessor -fopenmp -lomp/g' GEMTools/src/Makefile
  sed -i.bak 's/-fopenmp/-Xpreprocessor -fopenmp -lomp/g' GEMTools/tools/Makefile
  sed -i.bak 's/-fopenmp/-Xpreprocessor -fopenmp -lomp/g' GEMTools/test/Makefile
fi

make all
mkdir -p $PREFIX/bin
cp bin/bs_call $PREFIX/bin
cp bin/dbSNP_idx $PREFIX/bin

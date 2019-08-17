#!/bin/bash

#adding include and lib dirs to GEMTools and bs_call
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

./configure
if [[ "$OSTYPE" == "darwin"* ]]; then
  #forced disabling of openmp for macos
  make HAVE_OPENMP=0 all CC=$CC
else
  make all CC=$CC
fi
mkdir -p $PREFIX/bin
cp bin/bs_call $PREFIX/bin
cp bin/dbSNP_idx $PREFIX/bin

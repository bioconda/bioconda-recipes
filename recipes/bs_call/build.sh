#!/bin/bash

export CPATH=${PREFIX}/include

sed -i.bak '
    /^INCLUDE_FLAGS=/ s@$@ -I'$PREFIX'/include@
    /^LIB_PATH_FLAGS=/ s@$@ -L'$PREFIX'/lib@
  ' GEMTools/Makefile.mk


./configure
make all
mkdir -p $PREFIX/bin
cp bin/bs_call $PREFIX/bin
cp bin/dbSNP_idx $PREFIX/bin

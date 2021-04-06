#!/bin/bash

#changing arch to x86-64 and tuning down the optimizations to make the binary more general
#adding include and library paths in order to find bzip2
sed -i.bak '
    /^PATH_INCLUDE=/ s@$@ -I'$PREFIX'/include@
    /^PATH_LIB=/ s@$@ -L'$PREFIX'/lib@
    /FLAGS_OPT=/ s@-Ofast -march=native@-O3 -march=x86-64 -mtune=generic@
  ' Makefile.mk.in

export CFLAGS="${CFLAGS} -fcommon"
export CXXFLAGS="${CFLAGS} -fcommon"
export CC="${CC} -fcommon"
export CXX="${CXX} -fcommon"
./configure
make all
mkdir -p $PREFIX/bin
cp bin/* $PREFIX/bin

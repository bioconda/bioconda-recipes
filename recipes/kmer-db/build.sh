#!/bin/bash

uname_S=`uname -s 2>/dev/null || echo not`
if [ "$uname_S" == "Darwin" ]; then brew install gcc@12;

CFLAGS="$CFLAGS -I${PREFIX}/include"
LDFLAGS="$LDFLAGS -L${PREFIX}/lib"

make -j${CPU_COUNT} CXX=g++-12
install -d "${PREFIX}/bin"
install  kmer-db "${PREFIX}/bin"

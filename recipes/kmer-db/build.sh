#!/bin/bash

ln -s ${CC} gcc
ln -s ${CXX} g++
export PATH=$PATH:$(pwd)

CFLAGS="$CFLAGS -I${PREFIX}/include"
LDFLAGS="$LDFLAGS -L${PREFIX}/lib"

make -j${CPU_COUNT} 
install -d "${PREFIX}/bin"
install  kmer-db "${PREFIX}/bin"

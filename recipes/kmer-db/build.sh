#!/bin/bash


CFLAGS="$CFLAGS -I${PREFIX}/include"
LDFLAGS="$LDFLAGS -L${PREFIX}/lib"

make CC="${CXX}" 
install -d "${PREFIX}/bin"
install  kmer-db "${PREFIX}/bin"

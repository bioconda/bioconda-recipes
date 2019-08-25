#!/bin/bash

mkdir -p $PREFIX/bin

for OPT in AVX AVX2;
do
 if [[ "AVX2" == "${OPT}" ]]; then
    echo "Working on $OPT..."
    make CC=${GXX} CFLAGS="${CXXFLAGS}" LDFLAGS="${LDFLAGS}"
    cp kmer-db $PREFIX/bin/kmer-db-${OPT}
    make clean
 else
    echo "Working on $OPT..."
    make CC=${GXX} CFLAGS="${CXXFLAGS}" LDFLAGS="${LDFLAGS}" NO_AVX2=true
    echo "Trying to copy to $PREFIX"
    cp kmer-db $PREFIX/bin/kmer-db-${OPT}
    make clean
 fi
done


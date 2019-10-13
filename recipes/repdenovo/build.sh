#!/bin/bash
set -x -e

mkdir -p ${PREFIX}/bin

pushd TERefiner
make CC=$CXX BAMTOOLS_LD=${PREFIX}/lib BAMTOOLS=${PREFIX}/include
cp TERefiner_1 ${PREFIX}/bin/ 
popd

pushd ./ContigsCompactor-v0.2.0/ContigsMerger/ 
make CC=$CXX CFLAGS="$CXXFLAGS -L${PREFIX}/lib"
cp ContigsMerger ${PREFIX}/bin
popd

cp *.py ${PREFIX}/bin/
chmod +x ${PREFIX}/bin/*

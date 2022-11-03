#!/bin/bash
echo $PREFIX

echo "Binning compilation"
cd binning
make all CXX=${CXX}  ILIB="-I${BUILD_PREFIX}/include -L${BUILD_PREFIX}/lib"
mkdir -p $PREFIX/bin
cp binning $PREFIX/bin
cd ..

echo "genFm9 compilation"
cd genFm9
make all CPP=${CXX}  ILIB="-I${BUILD_PREFIX}/include -L${BUILD_PREFIX}/lib"
cp genFm9 $PREFIX/bin
cd ..

echo "mapping compilation"
cd mapping
make all CPP=${CXX}  ILIB="-I${BUILD_PREFIX}/include -L${BUILD_PREFIX}/lib"
cp mapping $PREFIX/bin
cd ..

echo "clame compilation"
make all CPP=${CXX}  ILIB="-I${BUILD_PREFIX}/include -L${BUILD_PREFIX}/lib"
cp clame $PREFIX/bin

echo "Installation successful"


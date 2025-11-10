#!/bin/bash
echo $PREFIX

sed -i '1c\CPP ?= $(CXX)' Makefile
sed -i '1c\CPP ?= $(CXX)' binning/Makefile
sed -i '1c\CPP ?= $(CXX)' genFm9/Makefile
sed -i '1c\CPP ?= $(CXX)' mapping/Makefile
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


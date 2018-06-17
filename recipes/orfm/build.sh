#!/bin/bash

echo ================================================
echo PREFIX="${PREFIX}"

echo CC="${CC}"
echo CXX="${CXX}"
echo CFLAGS="${CFLAGS}"
echo CXXFLAGS="${CXXFLAGS}"
echo CPPFLAGS="${CPPFLAGS}"
echo LDFLAGS="${LDFLAGS}"

echo INCLUDE_PATH="${INCLUDE_PATH}"
echo LIBRARY_PATH="${LIBRARY_PATH}"
echo LD_LIBRARY_PATH="${LD_LIBRARY_PATH}"
echo ================================================

cd $SRC_DIR/ext
wget -O seqtk.tar.gz https://github.com/lh3/seqtk/archive/d3b53c9.tar.gz
tar -xvf seqtk.tar.gz -C seqtk --strip-components 1
cd ..

mkdir -p $PREFIX/bin
autoreconf --install
./configure
make
mv orfm  $PREFIX/bin

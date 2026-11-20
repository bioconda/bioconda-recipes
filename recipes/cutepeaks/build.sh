#!/bin/bash
set -ex

export CFLAGS="$CFLAGS -I$PREFIX/include"
export CXXFLAGS="$CXXFLAGS -I$PREFIX/include"
export LDFLAGS="$LDFLAGS -L$PREFIX/lib"

#qmake bugfix: qmake fails if there is no g++ executable available, even if QMAKE_CXX is explicitly set
ln -s $CXX $BUILD_PREFIX/bin/g++
export PATH=$BUILD_PREFIX/bin/:$PATH



# Run qmake to generate a Makefile
qmake cutepeaks.pro QMAKE_CXX="$CXX" QMAKE_CC="$CC" QMAKE_CFLAGS="$CFLAGS $LDFLAGS" QMAKE_CXXFLAGS="$CXXFLAGS $LDFLAGS" QMAKE_RPATHDIR="${PREFIX}/lib/"

# Build the program
make

# Install
mkdir $PREFIX/bin
cp src/cutepeaks $PREFIX/bin

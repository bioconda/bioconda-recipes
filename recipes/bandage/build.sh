#!/bin/bash
set -ex

#qmake bugfix: qmake fails if there is no g++ executable available, even if QMAKE_CXX is explicitly set
ln -s $CXX $BUILD_PREFIX/bin/g++
export PATH=$BUILD_PREFIX/bin/:$PATH

# Run qmake to generate a Makefile
qmake Bandage.pro QMAKE_CXX="$CXX" QMAKE_CC="$CC" QMAKE_CFLAGS="$CFLAGS" QMAKE_CXXFLAGS="$CXXFLAGS"

# fix the makefile
sed -ie "s/isystem/I/" Makefile
# Build the program
make

# Install
mkdir $PREFIX/bin
cp Bandage $PREFIX/bin

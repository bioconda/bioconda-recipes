#!/bin/bash
set -ex

# Run qmake to generate a Makefile
qmake Bandage.pro QMAKE_CXX="$CXX" QMAKE_CC="$CC" QMAKE_CFLAGS="$CFLAGS" QMAKE_CXXFLAGS="$CXXFLAGS"
# DEBUG: what's in here now ?
cat Makefile

# fix the makefile
sed -ie "s/isystem/I/" Makefile
# Build the program
make

# Install
cp Bandage $PREFIX/bin

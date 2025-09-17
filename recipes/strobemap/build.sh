#!/bin/bash
#
# CONDA build script variables 
# 
# $PREFIX The install prefix
# $PKG_NAME The name of the package
# $PKG_VERSION The version of the package
# $PKG_BUILDNUM The build number of the package
#
set -eu -o pipefail

CFLAGS="$CFLAGS -I/usr/include"
LDFLAGS="$LDFLAGS -L/usr/lib"

mkdir -p $PREFIX/bin/

cd $SRC_DIR/
cp -r modules $PREFIX/bin/
cp -r evaluation $PREFIX/bin/

cd $SRC_DIR/strobemers_cpp
$CXX $CFLAGS $LDFLAGS -std=c++14 main.cpp index.cpp -lz -fopenmp -o StrobeMap -O3 -mavx2
cp StrobeMap $PREFIX/bin/
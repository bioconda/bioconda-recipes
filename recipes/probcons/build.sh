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


make -j ${CPU_COUNT} CC="$CC" CFLAGS="$CFLAGS" CXX="$CXX" CXXFLAGS="$CXXFLAGS -DNumInsertStates=2 -DVERSION=\"1.12\" -O3 -W -Wall -pedantic -DNDEBUG -funroll-loops"

# install probcons in the target bin directory 
mkdir -p $PREFIX/bin
cp probcons $PREFIX/bin
cp compare $PREFIX/bin

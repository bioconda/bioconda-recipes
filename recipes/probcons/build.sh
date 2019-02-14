#!/bin/bash
#
# CONDA build script variables 
# 
# $PREFIX The install prefix
# $PKG_NAME The name of the package
# $PKG_VERSION The version of the package
# $PKG_BUILDNUM The build number of the package
#

#patch the missing libraries
sed -i '26i#include <cstring>' Main.cc
sed -i '21i#include <cstring>' CompareToRef.cc
sed -i '21i#include <cstring>' ProjectPairwise.cc

make


# install tcoffee in the target bin directory 
mkdir -p $PREFIX/bin
cp probcons $PREFIX/bin
cp compare $PREFIX/bin
#!/bin/bash

export CPLUS_INCLUDE_PATH=${PREFIX}/include
export CPP_INCLUDE_PATH=${PREFIX}/include
export CXX_INCLUDE_PATH=${PREFIX}/include
export CPPFLAGS="-std=c++11"

# for troubleshooting with zlib
#export CPATH=${PREFIX}/include

# compile Crac 
./configure
make CXX="$CXX $CXXFLAGS" CPPFLAGS="$CPPFLAGS -I. -I$PREFIX/include"
make check
make install
make installcheck

# cp executables
mkdir -p $PREFIX/bin
cp -pf crac $PREFIX/bin

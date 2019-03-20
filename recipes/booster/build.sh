#!/bin/bash

CXXFLAGS="$CXXFLAGS";
LDFLAGS="$LDFLAGS -Wl,-rpath ${PREFIX}/lib";
CXX=g++;
CC=gcc;

if [ `uname` == Darwin ] ; then
    CXXFLAGS="$CXXFLAGS -stdlib=libc++"
    LDFLAGS="$LDFLAGS -stdlib=libc++"
    CXX=clang++;
    CC=clang;
else ## linux
    CXXFLAGS="$CXXFLAGS -fopenmp"
fi

export CC=${CC}
export CXX=${CXX}
export CXXFLAGS=${CXXFLAGS}
export LDFLAGS=${LDFLAGS}
            
cd $SRC_DIR/src
make

mkdir -p $PREFIX/bin
cp booster $PREFIX/bin


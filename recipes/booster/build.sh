#!/bin/bash

CXXFLAGS="$CXXFLAGS";
CFLAGS="$CFLAGS";
LDFLAGS="$LDFLAGS -Wl,-rpath ${PREFIX}/lib";
CXX=g++;
CC=gcc;

if [ `uname` == Darwin ] ; then
    CXXFLAGS="$CXXFLAGS -stdlib=libc++"
    CFLAGS="$CFLAGS -stdlib=libgcc"
    LDFLAGS="$LDFLAGS -stdlib=libc++"
    CXX=clang++;
    CC=clang;
else ## linux
    CXXFLAGS="$CXXFLAGS -fopenmp"
fi

export CC=${CC}
export CXX=${CXX}
export CXXFLAGS=${CXXFLAGS}
export CFLAGS=${CFLAGS}
export LDFLAGS=${LDFLAGS}
            
cd $SRC_DIR/src
make

mkdir -p $PREFIX/bin
cp booster $PREFIX/bin


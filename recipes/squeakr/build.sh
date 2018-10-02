#!/bin/bash

set -x -e

mkdir -p $PREFIX/bin

BUILD_OS=$(uname -s)

if [ ${BUILD_OS} == "Darwin" ]; then
   LDFLAGS="-stdlib=libc++ -L ${PREFIX}/lib" CXXFLAGS="-stdlib=libc++ -I ${PREFIX}/include" make
   else
   LDFLAGS="-L ${PREFIX}/lib" CXXFLAGS="-L ${PREFIX}/lib -I ${PREFIX}/include" make
fi

cp squeakr-count  $PREFIX/bin
cp squeakr-inner-prod $PREFIX/bin
cp squeakr-query $PREFIX/bin

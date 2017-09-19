#!/bin/bash

set -x -e

mkdir -p $PREFIX/bin

BUILD_OS=$(uname -s)

if [ ${BUILD_OS} == "Darwin" ]; then
   LDFLAGS="-stdlib=libc++" CXXFLAGS="-stdlib=libc++ -L ${PREFIX}/lib -I ${PREFIX}/include" make
   else
   CXXFLAGS="-L ${PREFIX}/lib -I ${PREFIX}/include" make
fi

cp squeakr-count  $PREFIX/bin
cp squeakr-inner-prod $PREFIX/bin
cp squeakr-query $PREFIX/bin

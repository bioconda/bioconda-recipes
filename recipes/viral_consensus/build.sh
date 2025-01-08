#!/bin/bash

set -xe

make -j"${CPU_COUNT}" CXX="$CXX" INCLUDE="-I${PREFIX}/include -Ihtslib" RELEASEFLAGS="$CPPFLAGS $CXXFLAGS -O3 $LDFLAGS"
mkdir -p $PREFIX/bin
cp viral_consensus $PREFIX/bin/

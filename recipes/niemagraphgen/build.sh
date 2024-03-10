#!/bin/bash

mkdir -p ${PREFIX}/bin
make CXX="$CXX" INCLUDE="-I${PREFIX}/include" RELEASEFLAGS="$CPPFLAGS $CXXFLAGS -O3 $LDFLAGS"
cp ngg_* ${PREFIX}/bin

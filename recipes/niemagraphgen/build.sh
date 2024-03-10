#!/bin/bash

mkdir -p ${PREFIX}/bin
make CXX="$CXX" INCLUDE="-I${PREFIX}/include" RELEASEFLAGS="$CPPFLAGS $CXXFLAGS $OUTFLAG $UINTFLAG -O3 $LDFLAGS"
cp ngg_* ${PREFIX}/bin

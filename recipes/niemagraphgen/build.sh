#!/bin/bash

mkdir -p ${PREFIX}/bin
make CXX="$CXX" INCLUDE="-I${PREFIX}/include" RELEASEFLAGS="-Wall -pedantic -std=c++11 -DOUTFAVITES -DNGG_UINT_32 -O3 $LDFLAGS"
cp ngg_* ${PREFIX}/bin

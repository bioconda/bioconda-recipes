#!/bin/bash
make CXX="$CXX" INCLUDE= RELEASEFLAGS="$CPPFLAGS $CXXFLAGS -O3 $LDFLAGS"
mkdir -p $PREFIX/bin
cp viral_consensus $PREFIX/bin/

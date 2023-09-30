#!/bin/bash
make CC="$CC" CXX="$CXX" CFLAGS="$CFLAGS" CPPFLAGS="$CPPFLAGS" CXXFLAGS="$CXXFLAGS" LDFLAGS="$LDFLAGS"
mkdir -p $PREFIX/bin
cp viral_consensus $PREFIX/bin/

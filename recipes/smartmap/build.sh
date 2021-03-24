#!/bin/bash

export CFLAGS="$CFLAGS -I$PREFIX/include"
export LDFLAGS="$LDFLAGS -L$PREFIX/lib"
export CPATH=${PREFIX}/include

pushd gzstream
make CXX="$CXX $CXXFLAGS -L${PREFIX}/lib" CPPFLAGS="$CPPFLAGS -I. -I$PREFIX/include" AR="$AR cr"
popd

pushd Default
make all
popd

mkdir -p $PREFIX/bin
cp SmartMapPrep $PREFIX/bin
cp SmartMapRNAPrep $PREFIX/bin
cp Default/SmartMap $PREFIX/bin

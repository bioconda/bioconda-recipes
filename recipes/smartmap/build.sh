#!/bin/bash

pushd gzstream
make CXX="$CXX $CXXFLAGS" CPPFLAGS="$CPPFLAGS -I. -I$PREFIX/include" AR="$AR cr"
popd

pushd Default
make all
popd

mkdir -p $PREFIX/bin
cp SmartMapPrep $PREFIX/bin
cp SmartMapRNAPrep $PREFIX/bin
cp Default/SmartMap $PREFIX/bin

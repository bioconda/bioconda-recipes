#!/bin/bash

pushd gzstream
# Avoid version file to be misinterpreted as C++20 version header file.
mv version version.txt
make CXX="$CXX $CXXFLAGS $CPPFLAGS $LDFLAGS" AR="$AR cr"
popd

pushd Default
make all CXX="$CXX $CXXFLAGS $CPPFLAGS $LDFLAGS" AR="$AR cr"
popd

mkdir -p $PREFIX/bin
cp SmartMapPrep $PREFIX/bin
cp SmartMapRNAPrep $PREFIX/bin
cp Default/SmartMap $PREFIX/bin

#!/bin/bash
make CC=$CXX OPTCFLAGS="$CXXFLAGS"
mkdir -p $PREFIX/bin/
cp RadSex/bin/radsex $PREFIX/bin/

#!/bin/bash
make CC=$CXX OPTCFLAGS="$CXXFLAGS -fpermissive"
mkdir -p $PREFIX/bin/
cp RadSex/bin/radsex $PREFIX/bin/

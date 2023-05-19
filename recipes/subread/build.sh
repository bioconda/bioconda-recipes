#!/bin/bash

mkdir -p "${PREFIX}/bin"
mkdir -p "${PREFIX}/annotation"

cd src
MAKEFILE=Makefile.Linux
if [ `uname` = "Darwin" ];
then
  MAKEFILE=Makefile.MacOS
fi
export C_INCLUDE_PATH=${PREFIX}/include
export LIBRARY_PATH=${PREFIX}/lib
make -f $MAKEFILE CC_EXEC="$CC -L$PREFIX/lib -fcommon"
cd ..
cp bin/utilities/* $PREFIX/bin
rm -r bin/utilities
cp bin/* $PREFIX/bin
cp annotation/* $PREFIX/annotation

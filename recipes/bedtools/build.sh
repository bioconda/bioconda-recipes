#!/bin/sh
export CPLUS_INCLUDE_PATH=${PREFIX}/include
export C_INCLUDE_PATH=${PREFIX}/include

sed -i.bak -e 's/#include <inttypes.h>/#include <cinttypes>/' src/utils/bedFile/bedFile.h
sed -i.bak -e 's/#include <inttypes.h>/#include <cinttypes>/' src/utils/BinTree/BinTree.h
sed -i.bak -e 's/#include <inttypes.h>/#include <cinttypes>/' src/randomBed/randomBed.h
sed -i.bak -e 's/#include <inttypes.h>/#include <cinttypes>/' src/split/splitBed.cpp
find . -name *.bak -delete

make install prefix=$PREFIX CXX=$CXX CC=$CC LDFLAGS="-L$PREFIX/lib"

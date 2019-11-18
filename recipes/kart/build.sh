#!/bin/bash

export C_INCLUDE_PATH=${PREFIX}/include
export LIBRARY_PATH=${PREFIX}/lib

make Compiler=$CXX CXX=$CXX CC=$CC  LDFLAGS="-L${PREFIX}/lib" CFLAGS="-I${PREFIX}/include -L${PREFIX}/lib" CXXFLAGS="-I${PREFIX}/include -L${PREFIX}/lib"
if [ ! -d $PREFIX/bin ] ; then
  mkdir $PREFIX/bin
fi

cp bin/kart bin/bwt_index $PREFIX/bin

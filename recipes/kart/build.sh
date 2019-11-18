#!/bin/bash

export CFLAGS="-I${PREFIX}/include -L${PREFIX}/lib" 
export CXXFLAGS="-I${PREFIX}/include -L${PREFIX}/lib"
export LDFLAGS="-L${PREFIX}/lib"

if [ ! -d $PREFIX/bin ] ; then
  mkdir $PREFIX/bin
fi

make Compiler=$CXX CXX=$CXX CC=$CC
cp bin/kart bin/bwt_index $PREFIX/bin

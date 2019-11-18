#!/bin/bash

export CFLAGS="-I${PREFIX}/include -L${PREFIX}/lib" CXXFLAGS="-I${PREFIX}/include -L${PREFIX}/lib"
export LDFLAGS="-L${PREFIX}/lib"

if [ ! -d $PREFIX/bin ] ; then
  mkdir $PREFIX/bin
fi

make
cp bin/kart bin/bwt_index $PREFIX/bin

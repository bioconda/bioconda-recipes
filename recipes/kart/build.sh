#!/bin/bash
if [ ! -d $PREFIX/bin ] ; then
  mkdir $PREFIX/bin
fi

make Compiler=$CXX CXX=$CXX CC=$CC LDFLAGS="-L${PREFIX}/lib" CFLAGS="-I${PREFIX}/include -L${PREFIX}/lib" CXXFLAGS="-I${PREFIX}/include -L${PREFIX}/lib"
cp bin/kart bin/bwt_index $PREFIX/bin

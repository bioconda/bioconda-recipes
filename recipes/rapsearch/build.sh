#!/bin/bash

export CFLAGS="-I$PREFIX/include"
export LDFLAGS="-L$PREFIX/lib"
export CPATH=${PREFIX}/include

make -C Src/ CXX=$CXX CXXFLAGS="$CXXFLAGS" INC="-I$PREFIX/include -I." LIBS=$PREFIX/lib
# copy binaries from the bin folder in the
# rapsearch archive to the conda bin folder
mv bin/rapsearch ${PREFIX}/bin/
mv bin/prerapsearch ${PREFIX}/bin/


#!/bin/bash
export C_INCLUDE_PATH=$PREFIX/include/
export CPLUS_INCLUDE_PATH=$PREFIX/include/
export LIBRARY_PATH=$PREFIX/lib
export LDFLAGS="$LDFLAGS -L$PREFIX/lib"
export LD_LIBRARY_PATH=$PREFIX/lib

cd src
make CXX=$CXX
mkdir -p $PREFIX/bin
cp rnabridge-denovo $PREFIX/bin
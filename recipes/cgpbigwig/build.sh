#!/bin/bash
mkdir -p $PREFIX/bin
make -C c clean
sed -i.bak "s#gcc#${CC}#" c/Makefile

# This is needed for the testing in the makefile to work
export LD_LIBRARY_PATH=${PREFIX}/lib
make -C c prefix=$PREFIX HTSLOC=$PREFIX/lib OPTINC="-I$PREFIX/include" LFLAGS="-L$PREFIX/lib"

cp bin/* $PREFIX/bin

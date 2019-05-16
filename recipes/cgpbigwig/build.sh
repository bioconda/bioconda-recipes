#!/bin/bash

mkdir -p $PREFIX/bin
make -C c clean
make -C c prefix=$PREFIX HTSLOC=$PREFIX/lib OPTINC="-I$PREFIX/include" LFLAGS="-L$PREFIX/lib"
cp bin/* $PREFIX/bin


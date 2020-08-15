#!/bin/bash

make INCLUDES="-I$PREFIX/include" CFLAGS="-L$PREFIX/lib"

cd paf2gfa
make INCLUDES="-I$PREFIX/include -I../" CFLAGS="-L$PREFIX/lib"

cd ..
mkdir -p $PREFIX/bin
cp gfatools $PREFIX/bin
cp paf2gfa/paf2gfa $PREFIX/bin

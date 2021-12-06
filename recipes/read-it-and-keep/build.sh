#!/bin/bash

cd src
make -I$PREFIX/ext/minimap2-2.22 -I$PREFIX/ext/gzstream -I$PREFIX/include and -L$PREFIX/lib $PREFIX/ext/minimap2-2.22/libminimap2.a $PREFIX/ext/gzstream/libgzstream.a -lz -lm
mkdir -p ${PREFIX}/bin
cp readItAndKeep ${PREFIX}/bin/

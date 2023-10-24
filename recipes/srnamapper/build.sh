#!/bin/bash


# zlib hack
make CC=$CC INCLUDES="-I$PREFIX/include" CFLAGS+="-g -Wall -O2 -L$PREFIX/lib"
chmod +x srnaMapper
mkdir -p ${PREFIX}/bin
cp -f srnaMapper ${PREFIX}/bin

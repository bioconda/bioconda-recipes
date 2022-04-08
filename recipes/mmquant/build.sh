#!/bin/bash

# zlib hack
make CXX=$CXX INCLUDES="-I$PREFIX/include" CFLAGS+="-L$PREFIX/lib"
chmod +x mmquant
mkdir -p ${PREFIX}/bin
cp -f mmquant ${PREFIX}/bin

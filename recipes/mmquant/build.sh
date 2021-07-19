#!/bin/bash

# zlib hack
make CC=$CC INCLUDES="-I$PREFIX/include" CFLAGS+="-L$PREFIX/lib"
chmod +x mmquant
mkdir -p ${PREFIX}/bin
cp -f mmquant ${PREFIX}/bin

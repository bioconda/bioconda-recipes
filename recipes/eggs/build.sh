#!/bin/bash
make CC="${CC}" CFLAGS="-I${PREFIX}/include -c -Wall -g -I lib" LFLAGS="-L${PREFIX}/lib -g -o"
mkdir -p "$PREFIX/bin"
cp bin/eggs "$PREFIX/bin"
chmod +x "$PREFIX/bin/eggs"

#!/bin/bash

# zlib hack
echo -e "export CFLAGS=\"$CFLAGS -I$PREFIX/include\"\nexport LDFLAGS=\"$LDFLAGS -L$PREFIX/lib -lz\"\nexport CPATH=${PREFIX}/include\n$(cat Makefile)" > MakefileA
sed -i 's/CFLAGS =/CFLAGS +=/' Makefile
make CC=$CC INCLUDES="-I$PREFIX/include" CFLAGS+="-g -Wall -O2 -Wc++-compat -L$PREFIX/lib"
chmod +x srnaMapper
mkdir -p ${PREFIX}/bin
cp -f srnaMapper ${PREFIX}/bin

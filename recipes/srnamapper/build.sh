#!/bin/bash

# zlib hack
sed -i 's/-lz//' Makefile
echo -e "export CFLAGS=\"$CFLAGS -I$PREFIX/include\"\nexport LDFLAGS=\"$LDFLAGS -L$PREFIX/lib -lz\"\nexport CPATH=${PREFIX}/include\n$(cat Makefile)" > Makefile
sed -i 's/CFLAGS =/CFLAGS +=/' Makefile

make CC=$CC
chmod +x srnaMapper
mkdir -p ${PREFIX}/bin
cp -f srnaMapper ${PREFIX}/bin

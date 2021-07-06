#!/bin/bash

# Use $(CC), not "gcc"
sed -i '1d' Makefile
# zlib hack
echo -e "export CFLAGS=\"$CFLAGS -I$PREFIX/include\"\nexport LDFLAGS=\"$LDFLAGS -L$PREFIX/lib\"\nexport CPATH=${PREFIX}/include\n$(cat Makefile)" > Makefile

make
chmod +x srnaMapper
mkdir -p ${PREFIX}/bin
cp -f srnaMapper ${PREFIX}/bin

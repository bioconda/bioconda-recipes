#!/bin/bash

mkdir -p ${PREFIX}/bin

export CFLAGS="$CFLAGS -I$PREFIX/include"
export LDFLAGS="$LDFLAGS -L$PREFIX/lib"

make clean
make CC=${CC}

chmod +x fastqtk
cp fastqtk ${PREFIX}/bin/fastqtk

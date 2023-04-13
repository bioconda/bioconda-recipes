#!/bin/bash

mkdir -p ${PREFIX}/bin

export CFLAGS="$CFLAGS -I$PREFIX/include"
export LDFLAGS="$LDFLAGS -L$PREFIX/lib"

make clean

if [ "$(uname)" == "Darwin" ]; then
	# clang++ is required for OSX build
	make CC=${CXX}
else
	make CC=${CC}
fi

chmod +x fastqtk
cp fastqtk ${PREFIX}/bin/fastqtk

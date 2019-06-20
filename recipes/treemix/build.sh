#!/bin/bash

export LD_LIBRARY_PATH=${PREFIX}/lib
export CFLAGS="-I$PREFIX/include"
export CPATH=${PREFIX}/include

./configure --prefix=${PREFIX} CPPFLAGS="-I${PREFIX}/include" LDFLAGS="-L${PREFIX}/lib" --with-boost=${PREFIX}

make -j 2
make install
cp src/plotting_funcs.R ${PREFIX}/bin
chmod +x ${PREFIX}/bin/plotting_funcs.R

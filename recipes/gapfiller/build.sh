#!/bin/bash

export LDFLAGS="-L/${PREFIX}/lib"
export CFLAGS="-I${PREFIX}/include"
export CPPFLAGS="${CFLAGS}"
export LIBS='-lz'

./configure --with-boost=${PREFIX} --prefix=${PREFIX}
make
make install

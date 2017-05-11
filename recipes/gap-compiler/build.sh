#!/bin/sh
./configure --with-boost=${PREFIX} CPPFLAGS=-I${PREFIX} --prefix=$PREFIX --disable-gsltest
make
make install
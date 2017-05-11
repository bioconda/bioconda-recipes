#!/bin/sh
./configure  CPPFLAGS=-I${PREFIX} --prefix=$PREFIX --disable-gsltest
make
make install
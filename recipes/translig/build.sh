#!/bin/bash
export BOOST_ROOT=${PREFIX}
export CFLAGS="$CFLAGS $LDFLAGS"
./configure --prefix=${PREFIX} --with-boost-libdir=${PREFIX}/lib
make

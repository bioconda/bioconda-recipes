#!/bin/sh
CFLAGS=-pthread
export CFLAGS
./configure --prefix=${PREFIX} --enable-pthreads
make
make install

#!/bin/sh

./configure --prefix=$PREFIX --with-hash-bits=27 CFLAGS='-mcmodel=large' && \
make && \
make install

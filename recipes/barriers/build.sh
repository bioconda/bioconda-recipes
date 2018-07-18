#!/bin/sh

./autogen.sh
./configure --prefix=$PREFIX --with-hash-bits=27 CFLAGS='-mcmodel=large' || (cat config.log ; exit 1)
make
make install

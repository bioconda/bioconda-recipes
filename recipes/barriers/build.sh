#!/bin/sh

./autogen.sh
#./configure --prefix=$PREFIX --with-hash-bits=27 CFLAGS='-mcmodel=medium' || (cat config.log ; exit 1)
./configure --prefix=$PREFIX || (cat config.log ; exit 1)
make
make install

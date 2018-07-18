#!/bin/sh

./autogen.sh || (cat config.log ; exit 1)
./configure --prefix=$PREFIX --with-hash-bits=27 CFLAGS='-mcmodel=large' || (cat config.log ; exit 1)
make || (cat config.log ; exit 1)
make install || (cat config.log ; exit 1)

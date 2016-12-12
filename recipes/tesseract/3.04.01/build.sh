#!/usr/bin/env bash

./autogen.sh
LIBLEPT_HEADERSDIR=$PREFIX/include ./configure --prefix=$PREFIX --with-extra-libraries=$PREFIX/lib
LDFLAGS="-L$PREFIX/lib" CFLAGS="-I$PREFIX/include" make
make install

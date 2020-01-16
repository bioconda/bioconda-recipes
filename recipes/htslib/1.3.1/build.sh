#!/bin/bash

./configure --prefix=$PREFIX --enable-libcurl CFLAGS="-I$PREFIX/include" LDFLAGS="-L$PREFIX/lib"
make install prefix=$PREFIX CC=$CC

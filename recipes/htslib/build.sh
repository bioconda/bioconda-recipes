#!/bin/bash

./configure CFLAGS="-DHAVE_LIBDEFLATE" CPPFLAGS="-DHAVE_LIBDEFLATE -I$PREFIX/include" --prefix=$PREFIX --enable-libcurl CFLAGS="-I$PREFIX/include" LDFLAGS="-L$PREFIX/lib"
make install prefix=$PREFIX

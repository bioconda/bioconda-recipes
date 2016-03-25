#!/usr/bin/env bash

LDFLAGS="-Wl,-rpath -Wl,$PREFIX/lib" CFLAGS="-I$PREFIX/include" sh ./configure --prefix=$PREFIX
make
make install

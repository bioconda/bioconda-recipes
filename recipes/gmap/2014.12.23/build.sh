#!/bin/sh
env MAX_READLENGTH=500 ./configure --prefix=$PREFIX --enable-zlib
make
make install prefix=$PREFIX

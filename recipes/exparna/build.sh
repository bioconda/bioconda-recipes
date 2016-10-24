#!/bin/sh
./configure --prefix=$PREFIX --with-RNA=prefix
make clean
make
make install

#!/bin/sh
./configure --prefix=$PREFIX --with-RNA=$PREFIX/inlude
make clean
make
make install

#!/bin/sh
./configure --prefix=$PREFIX --with-RNA=$PREFIX
make clean
make
make install

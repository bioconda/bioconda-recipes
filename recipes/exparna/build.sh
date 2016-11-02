#!/bin/sh
bash autotools-init.sh
./configure --prefix=$PREFIX --with-RNA=$PREFIX -q
make clean
make
make install

#!/bin/bash

#MEME_ETC_DIR=${PREFIX}/etc
perl scripts/dependencies.pl
./configure --prefix="$PREFIX"
make clean
#make AM_CFLAGS='-DNAN="(0.0/0.0)"'
make install

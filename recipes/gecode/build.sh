#!/bin/sh
./configure --prefix=$PREFIX --disable-qt --disable-examples

make -j4
make install

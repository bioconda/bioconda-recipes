#!/bin/sh

cd Misc/Applications/RNAshapes/
./configure --prefix=$PREFIX
make
make install
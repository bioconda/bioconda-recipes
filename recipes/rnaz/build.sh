#!/bin/bash
./configure --prefix=$PREFIX --datadir=$PREFIX/share
make
make install

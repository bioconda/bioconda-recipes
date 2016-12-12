#!/bin/sh
./configure --prefix=$PREFIX --disable-dependency-tracking
make
make install

#!/bin/sh
./configure  --enable-threads --prefix=$PREFIX
make
make install --always-make

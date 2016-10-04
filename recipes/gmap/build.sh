#!/bin/sh
./configure MAX_READLENGTH=500 --prefix=$PREFIX
make
make install prefix=$PREFIX

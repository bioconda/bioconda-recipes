#!/bin/sh

./configure --prefix=$PREFIX
make -j4
make install

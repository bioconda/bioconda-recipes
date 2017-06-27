#!/bin/bash

export LIBS="-liconv"
./configure \
    --prefix=$PREFIX \
    --without-x \
    --without-lua

make && make install

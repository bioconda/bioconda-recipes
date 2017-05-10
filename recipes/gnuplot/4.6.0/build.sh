#!/bin/bash

./prepare
./configure \
    --prefix=$PREFIX \
    --without-x \
    --without-lua

make && make install

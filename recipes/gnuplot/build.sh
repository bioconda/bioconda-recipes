#!/bin/bash

./configure \
    --prefix=$PREFIX \
    --without-x \
    --without-fontconfig

make && make install

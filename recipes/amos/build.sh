#!/bin/bash

rm -rf test tutorial
./configure \
    --prefix=$PREFIX
make
make install

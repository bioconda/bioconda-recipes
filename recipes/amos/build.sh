#!/bin/bash

rm -r test tutorial
./bootstrap
./configure \
    --prefix=$PREFIX
make
make install

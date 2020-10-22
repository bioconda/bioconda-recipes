#!/bin/bash

export CPATH=${PREFIX}/include

./configure --prefix=$PREFIX
make
make install

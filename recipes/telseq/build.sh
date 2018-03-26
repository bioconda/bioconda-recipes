#!/bin/bash

export CC=gcc
export CXX=g++

cd $SRC_DIR/src
./autogen.sh
./configure --prefix=$PREFIX --with-bamtools=$PREFIX
make
make install

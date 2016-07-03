#!/bin/bash

pushd $SRC_DIR

aclocal
./configure --prefix=$PREFIX
make
make install

#!/bin/bash

cd $SRC_DIR/src
./autogen.sh
./configure --prefix=$PREFIX
make
make install

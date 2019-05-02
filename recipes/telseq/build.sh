#!/bin/bash

cd $SRC_DIR/src
./autogen.sh
./configure --prefix=$PREFIX --with-bamtools=$BUILD_PREFIX
make
make install

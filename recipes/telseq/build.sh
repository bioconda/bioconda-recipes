#!/bin/bash

cd $SRC_DIR/src
./autogen.sh
./configure --prefix=$PREFIX --with-bamtools=$PREFIX/include/bamtools
make
make install

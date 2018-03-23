#!/bin/bash

cd $SRC_DIR/src
./autogen.sh
./configure --prefix=$PREFIX --with-bamtools=$PREFIX
make
make install

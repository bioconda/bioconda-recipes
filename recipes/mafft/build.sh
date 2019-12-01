#!/bin/bash

# cd to location of Makefile and source
cd $SRC_DIR/core

make CC=$CC CFLAGS=$CFLAGS PREFIX=$PREFIX
make install

#!/bin/bash

# cd to location of Makefile and source
cd $SRC_DIR/core

export PRFX=$PREFIX
make CC=${CC} CXX=${CXX}
make install

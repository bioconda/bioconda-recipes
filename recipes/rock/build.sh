#!/bin/bash

# cd to location of Makefile and source
cd $SRC_DIR

# depends on automake, autoconf
autoconf
aclocal
automake
./configure --prefix=$PREFIX
make
make install
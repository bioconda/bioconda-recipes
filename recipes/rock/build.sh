#!/bin/bash

# cd to location of Makefile and source
cd $SRC_DIR

# depends on automake, autoconf
aclocal
autoconf
automake
./configure --prefix=$PREFIX --disable-dependency-tracking
make
make install
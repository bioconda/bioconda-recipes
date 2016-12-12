#!/bin/bash

# cd to location of Makefile and source
cd $SRC_DIR/gnuac

# depends on automake, autoconf
aclocal
autoheader
automake -a -c
autoconf
./configure --prefix=$PREFIX
make
make install 
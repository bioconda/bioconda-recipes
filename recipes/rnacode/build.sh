#!/bin/sh
./configure --prefix=$PREFIX 
make CFLAGS="$CFLAGS -fcommon"
make install

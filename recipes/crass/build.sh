#!/bin/bash

./autogen.sh
./configure --prefix=${PREFIX} --with-xerces=${PREFIX} CPPFLAGS="$CPPFLAGS" LDFLAGS="$LDFLAGS"
make
make install

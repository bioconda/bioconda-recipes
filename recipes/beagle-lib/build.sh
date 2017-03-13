#!/bin/bash

export LDFLAGS="-L${PREFIX}/lib"
./autogen.sh
./configure --prefix=${PREFIX} --with-jdk=${PREFIX}
make
make install

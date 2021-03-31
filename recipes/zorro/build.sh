#!/bin/bash

cd probmask/ || true
cd trunk/

./autogen.sh
./configure --prefix=${PREFIX}
export CFLAGS="${CFLAGS} -fcommon"

make
make install

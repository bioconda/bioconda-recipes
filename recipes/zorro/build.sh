#!/bin/bash

cd probmask/ || true
cd trunk/

./autogen.sh
./configure --prefix=${PREFIX}

make
make install

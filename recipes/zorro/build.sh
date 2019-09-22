#!/bin/bash

cd probmask/trunk/

./autogen.sh
./configure --prefix=${PREFIX}

make
make install

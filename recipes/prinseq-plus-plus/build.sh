#!/bin/bash
set +ex

./autogen.sh
./configure --prefix=${PREFIX} --with-boost=${PREFIX} 
make
make install

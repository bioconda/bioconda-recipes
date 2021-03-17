#!/bin/bash
export LIBS="-lstdc++fs -lcurl -lio_lib"

./configure --prefix $PREFIX --with-snappy

#debug
echo "START CONFIG.LOG"
cat config.log
echo "END CONFIG.LOG"

make
make install

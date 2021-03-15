#!/bin/bash
set -eu
export LIBS="-lstdc++fs -lcurl -lio_lib"

./configure --prefix $PREFIX --with-snappy --with-io_lib

#debug
echo "START CONFIG.LOG"
cat config.log
echo "END CONFIG.LOG"

make
make install

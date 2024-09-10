#!/bin/bash
set -eu
export LIBS="-lstdc++fs -lcurl"

./configure --prefix $PREFIX --with-snappy --with-io_lib

cat config.log

make -j${CPU_COUNT}
make install

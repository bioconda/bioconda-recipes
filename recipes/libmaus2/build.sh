#!/bin/bash
set -eu
export LIBS="-lstdc++fs -lcurl"
export CPPFLAGS="${CPPFLAGS} -fno-rtti"

./configure --prefix $PREFIX --with-snappy --with-io_lib

cat config.log

make
make install

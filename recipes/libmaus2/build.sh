#!/bin/bash
set -eu
export LIBS="-lcurl"

./configure --prefix $PREFIX --with-snappy --with-io_lib

cat config.log

make
make install

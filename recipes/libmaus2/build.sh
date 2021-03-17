#!/bin/bash
set -eu

./configure --prefix $PREFIX --with-snappy --with-io_lib || cat config.log

make
make install

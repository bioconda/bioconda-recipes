#!/bin/sh
set -ex
grep -r automake
./configure --prefix=$PREFIX || (cat config.log ; exit 1)
make
make install

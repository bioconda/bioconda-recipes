#!/bin/sh
set -ex
grep -r automake
./configure --prefix=$PREFIX || (cat config.log ; exit 1)
cat src Makefile
make
make install

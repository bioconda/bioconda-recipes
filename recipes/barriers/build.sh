#!/bin/sh
set -ex
./configure --prefix=$PREFIX || (cat config.log ; exit 1)
grep automake src/Makefile
make AUTOMAKE=automake AUTOCONF=autoconf
make install

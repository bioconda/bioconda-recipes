#!/bin/sh

./configure --prefix=$PREFIX || (cat config.log ; exit 1)
cat Makefile
make
make install

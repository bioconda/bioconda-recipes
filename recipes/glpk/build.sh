#!/bin/bash

CC=${PREFIX}/bin/gcc
CXX=${PREFIX}/bin/g++

export CFLAGS="-O3"

./configure --prefix=$PREFIX --with-gmp-prefix=$PREFIX

make check install

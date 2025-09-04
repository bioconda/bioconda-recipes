#!/bin/bash

mkdir -p $PREFIX/bin

./configure --prefix=$PREFIX

make -j"${CPU_COUNT}"
make install

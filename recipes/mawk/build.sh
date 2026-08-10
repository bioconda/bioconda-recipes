#!/bin/bash

mkdir -p $PREFIX/bin

cp -f ${BUILD_PREFIX}/share/gnuconfig/config.* .

./configure --prefix=$PREFIX

make -j"${CPU_COUNT}"
make install

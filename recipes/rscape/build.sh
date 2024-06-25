#!/usr/bin/env bash

set -xe

./configure --disable-avx512 --prefix=$PREFIX

make V=1 -j ${CPU_COUNT}
make install

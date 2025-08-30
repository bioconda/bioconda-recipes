#!/bin/bash

sed -i 's/AM_INIT_AUTOMAKE/AM_INIT_AUTOMAKE([subdir-objects])/' configure.ac

set -ex
# 创建缺失的规范文件
touch AUTHORS ChangeLog NEWS README echo "QUIP Compression Tool" > AUTHORS echo "Initial conda package version" > NEWS
export CFLAGS="-I$PREFIX/include"
export LDFLAGS="-L$PREFIX/lib"
export LIBS="-L$PREFIX/lib"
export CPATH=${PREFIX}/include
autoreconf -i --verbose
./configure --prefix=$PREFIX
make install

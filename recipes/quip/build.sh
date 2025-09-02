#!/bin/bash
set -ex

export CFLAGS="${CFLAGS} -O3 -I$PREFIX/include"
export LDFLAGS="${LDFLAGS} -L$PREFIX/lib"
export LIBS="-L$PREFIX/lib"
export CPATH="${PREFIX}/include"

# 创建缺失的规范文件
touch AUTHORS ChangeLog NEWS README echo "QUIP Compression Tool" > AUTHORS echo "Initial conda package version" > NEWS

sed -i'' -e 's/AM_INIT_AUTOMAKE/AM_INIT_AUTOMAKE([subdir-objects])/' configure.ac

autoreconf -i --verbose

./configure --prefix="$PREFIX"
make install -j"${CPU_COUNT}"

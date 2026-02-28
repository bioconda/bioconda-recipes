#!/bin/bash
set -ex

export CFLAGS="${CFLAGS} -O3 -Wno-strict-prototypes"
export LDFLAGS="${LDFLAGS} -L$PREFIX/lib"
export CPPFLAGS="${CPPFLAGS} -I${PREFIX}/include"
export LIBS="-L$PREFIX/lib"
export CPATH="${PREFIX}/include"

# 创建缺失的规范文件
touch AUTHORS ChangeLog NEWS README echo "QUIP Compression Tool" > AUTHORS echo "Initial conda package version" > NEWS

sed -i'' -e 's/AM_INIT_AUTOMAKE/AM_INIT_AUTOMAKE([subdir-objects])/' configure.ac

autoreconf -if

./configure --prefix="$PREFIX" \
  CC="${CC}" \
  CFLAGS="${CFLAGS}" \
  LDFLAGS="${LDFLAGS}" \
  CPPFLAGS="${CPPFLAGS}"

make install -j"${CPU_COUNT}"

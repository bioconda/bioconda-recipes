#!/bin/sh
set -e
export CFLAGS="${CFLAGS} -fcommon"
export CXXFLAGS="${CXXFLAGS} -fcommon"

# use newer config.guess and config.sub that support linux-aarch64
cp -rf ${RECIPE_DIR}/config.* .

./configure --prefix=$PREFIX
make
make check
make install

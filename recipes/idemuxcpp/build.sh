#!/bin/sh

set -xe

./configure --enable-tests --prefix="${PREFIX}" --disable-bamtools
make -j ${CPU_COUNT}
make install
make check

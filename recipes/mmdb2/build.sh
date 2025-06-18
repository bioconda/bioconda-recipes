#!/bin/bash

set -exo pipefail

cp ${BUILD_PREFIX}/share/gnuconfig/config.* build-aux/

./configure \
    --prefix=${PREFIX} \
    --enable-shared \
    --disable-static \
    --disable-debug \
    --disable-dependency-tracking

make -j${CPU_COUNT}
make install

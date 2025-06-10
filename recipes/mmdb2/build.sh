#!/bin/bash

set -exo pipefail

./configure \
    --prefix=${PREFIX} \
    --enable-shared \
    --disable-static \
    --disable-debug \
    --disable-dependency-tracking

make -j${CPU_COUNT}
make install

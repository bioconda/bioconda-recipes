#!/bin/bash

set -exo pipefail

cp ${BUILD_PREFIX}/share/gnuconfig/config.* build-aux/
sed -i.bak 's/int putenv ();/extern int putenv (char *);/' ccp4/library_utils.c

./configure \
    --prefix=${PREFIX} \
    --enable-shared \
    --enable-fortran \
    --disable-static \
    --disable-debug \
    --disable-dependency-tracking

make -j${CPU_COUNT}
make install

#!/bin/bash

set -exo pipefail

sed -i.bak 's/int putenv ();/extern int putenv (char *);/' ccp4/library_utils.c

./configure \
    --prefix=${PREFIX} \
    --enable-shared \
    --disable-static \
    --disable-fortran

make -j${CPU_COUNT}
make install

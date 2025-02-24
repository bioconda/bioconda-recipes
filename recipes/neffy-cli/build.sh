#!/bin/bash -euo

set -xe

make -j"${CPU_COUNT}" CC=$CC CFLAGS="$CFLAGS

if [ ! -d ${PREFIX}/bin ] ; then
    mkdir -p ${PREFIX}/bin
fi

cp converter ${PREFIX}/bin
cp neff ${PREFIX}/bin

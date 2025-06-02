#!/bin/bash

set -xe

scripts/install-zstd.sh
./configure  --enable-localzstd
pushd slow5lib
make -j ${CPU_COUNT} CC=$CC CXX=$CXX 
popd

export CFLAGS="${CFLAGS} -D__STDC_FORMAT_MACROS"
make -j ${CPU_COUNT} CC=$CC CXX=$CXX 
mkdir -p $PREFIX/bin
cp -f slow5tools $PREFIX/bin/slow5tools
chmod 0755 $PREFIX/bin/slow5tools
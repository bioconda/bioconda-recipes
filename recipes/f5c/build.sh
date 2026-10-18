#!/bin/bash
set -xe

export LDFLAGS="${LDFLAGS} -L${PREFIX}/lib"
export CPPFLAGS="${CPPFLAGS} -I${PREFIX}/include"

mkdir -p "$PREFIX/bin"

scripts/install-hts.sh
scripts/install-zstd.sh

./configure  --enable-localzstd

cd slow5lib
make -j ${CPU_COUNT} CC=$CC CXX=$CXX
cd ..

export CFLAGS="${CFLAGS} -O3 -D__STDC_FORMAT_MACROS"
make CC="$CC" CXX="$CXX" -j"${CPU_COUNT}"

install -v -m 0755 f5c "$PREFIX/bin"

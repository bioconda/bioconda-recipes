#!/bin/bash

export CFLAGS="${CFLAGS} -I$PREFIX/include -O3"
export LDFLAGS="${LDFLAGS} -L$PREFIX/lib -Wl,-rpath,$PREFIX/lib"
if [[ "$target_platform" == linux-* ]]; then
  EXTRA_ARGS+=" --enable-gcs --enable-s3"
fi

autoreconf -if
./configure \
  --prefix="${PREFIX}" \
  --enable-libcurl \
  --with-libdeflate \
  --enable-plugins

make -j"${CPU_COUNT}"
make install

#!/bin/bash
export CC=aarch64-conda-linux-gnu-gcc
export AR=aarch64-conda-linux-gnu-ar
export RANLIB=aarch64-conda-linux-gnu-ranlib
export CFLAGS="-I$PREFIX/include -O2"
export LDFLAGS="-L$PREFIX/lib -Wl,-rpath,$PREFIX/lib"
EXTRA_ARGS=""
if [[ "$target_platform" == linux-* ]]; then
  EXTRA_ARGS+=" --enable-gcs --enable-s3"
fi

./configure \
  --prefix=$PREFIX \
  --host=aarch64-conda-linux-gnu \  # 关键：指定目标平台
  --enable-libcurl \
  --with-libdeflate \
  --enable-plugins \
  $EXTRA_ARGS
make install

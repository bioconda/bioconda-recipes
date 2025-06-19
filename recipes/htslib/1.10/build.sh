#!/bin/bash
export CFLAGS="-I${PREFIX}/include"
export LDFLAGS="-L${PREFIX}/lib"
EXTRA_ARGS=""
if [[ "$(uname)" == "Linux" ]]; then
  EXTRA_ARGS+=" --enable-gcs --enable-s3"
fi
./configure \
  --prefix=${PREFIX} \
  --enable-libcurl \
  --with-libdeflate \
  --enable-plugins \
  ${EXTRA_ARGS}

make install

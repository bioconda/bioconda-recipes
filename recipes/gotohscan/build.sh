#!/bin/bash

install -d "${PREFIX}/bin"

export CPPFLAGS="${CPPFLAGS} -I${PREFIX}/include"
export LDFLAGS="${LDFLAGS} -L${PREFIX}/lib"
export CFLAGS="${CFLAGS} -O3 -Wno-deprecated-declarations"

autoreconf -if
./configure --prefix="${PREFIX}" \
  --disable-option-checking \
  --enable-silent-rules \
  --disable-dependency-tracking \
  CC="${CC} -fcommon" \
  CFLAGS="${CFLAGS}" \
  LDFLAGS="${LDFLAGS}" \
  CPPFLAGS="${CPPFLAGS}"

make -j"${CPU_COUNT}"

make install

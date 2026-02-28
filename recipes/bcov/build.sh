#!/bin/bash

export CPPFLAGS="${CPPFLAGS} -I${PREFIX}/include"
export LDFLAGS="${LDFLAGS} -L${PREFIX}/lib"
export CFLAGS="${CFLAGS} -O3 -Wno-implicit-function-declaration -Wno-implicit-int"

cp -f ${BUILD_PREFIX}/share/gnuconfig/config.* .

autoreconf -fi
./configure --prefix="${PREFIX}" \
  CC="${CC}" \
  CFLAGS="${CFLAGS}" \
  CPPFLAGS="${CPPFLAGS}" \
  LDFLAGS="${LDFLAGS}"

make
make install

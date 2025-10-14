#!/bin/bash

export CPPFLAGS="${CPPFLAGS} -I${PREFIX}/include"
export LDFLAGS="${LDFLAGS} -L${PREFIX}/lib"

cp -f ${BUILD_PREFIX}/share/gnuconfig/config.* .

autoreconf -fi
./configure --prefix="${PREFIX}"

make
make install

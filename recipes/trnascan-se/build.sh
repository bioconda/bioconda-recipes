#!/bin/bash

export INCLUDE_PATH=${PREFIX}/include
export LIBRARY_PATH=${PREFIX}/lib
export LDFLAGS="${LDFLAGS} -L${PREFIX}/lib"
export CFLAGS="${CFLAGS} -O3 -I${PREFIX}/include ${LDFLAGS}"

sed -i.bak '1 s|^.*$|#!/usr/bin/env perl|g' tRNAscan-SE.src
sed -i.bak '1 s|^.*$|#!/usr/bin/env perl|g' src/instman.pl

./configure CC="${CC}" CFLAGS="${CFLAGS}" --prefix="${PREFIX}"

make
make install

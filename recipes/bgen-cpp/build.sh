#!/bin/bash

set -euxo pipefail

mkdir -p $PREFIX/bin

./waf configure \
    --prefix=${PREFIX} \
    --bindir=${PREFIX}/bin \
    --libdir=${PREFIX}/lib \
    CFLAGS="${CFLAGS} -I${PREFIX}/include LDFLAGS="${LDFLAGS} -L${PREFIX}/lib"

./waf

cp build/apps/bgenix ${PREFIX}/bin
cp build/apps/cat-bgen ${PREFIX}/bin
cp build/apps/edit-bgen ${PREFIX}/bin
#!/bin/bash

set -xe

mkdir -p ${PREFIX}/bin ${PREFIX}/lib ${PREFIX}/include

case $(uname -m) in
    aarch64)
        ARCH_OPTS="aarch64=1"
        ;;
    *)
        ARCH_OPTS=""
        ;;
esac

make CFLAGS="-g -Wall -O2 -Wc++-compat -I${PREFIX}/include -L${PREFIX}/lib" \
    ${ARCH_OPTS} -j${CPU_COUNT} minimap2 sdust

chmod 755 minimap2 && chmod 755 sdust

cp minimap2 misc/paftools.js ${PREFIX}/bin
cp sdust ${PREFIX}/bin
cp libminimap2.a ${PREFIX}/lib
cp *.h ${PREFIX}/include

#!/bin/bash

set -xe

mkdir -p ${PREFIX}/bin ${PREFIX}/lib ${PREFIX}/include $PREFIX/share/man/man1

case $(uname -m) in
    aarch64)
        ARCH_OPTS="aarch64=1"
        ;;
    arm64)
	ARCH_OPTS="aarch64=1"
        ;;
    *)
        ARCH_OPTS=""
        ;;
esac

make CFLAGS="${CFLAGS} -g -Wall -O3 -Wc++-compat -I${PREFIX}/include -L${PREFIX}/lib" \
    "${ARCH_OPTS}" -j"${CPU_COUNT}" minimap2 sdust

chmod 755 minimap2 && chmod 755 sdust

cp -rf minimap2 misc/paftools.js ${PREFIX}/bin
cp -rf sdust ${PREFIX}/bin
cp -rf libminimap2.a ${PREFIX}/lib
cp -rf *.h ${PREFIX}/include

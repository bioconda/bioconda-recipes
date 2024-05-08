#!/bin/bash

mkdir -p ${PREFIX}/bin ${PREFIX}/lib ${PREFIX}/include

export INCLUDE_PATH="${PREFIX}/include"

ARCH=$(uname -m)
case ${ARCH} in
    aarch64) ARCH_FLAGS="aarch64=1 arm_neon=" ;;
    *) ARCH_FLAGS="aarch64=" ;;
esac

make INCLUDES="-I${PREFIX}/include" CFLAGS="-g -Wall -O2 -Wc++-compat -L${PREFIX}/lib" \
	"${ARCH_FLAGS}" -j"${CPU_COUNT}" minimap2 sdust

chmod 755 minimap2 && chmod 755 sdust

cp -f minimap2 misc/paftools.js ${PREFIX}/bin
cp -f sdust ${PREFIX}/bin
cp -f libminimap2.a ${PREFIX}/lib
cp -f *.h ${PREFIX}/include

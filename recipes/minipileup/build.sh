#!/bin/bash

set -xe

mkdir -p ${PREFIX}/bin

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
    "${ARCH_OPTS}" -j"${CPU_COUNT}" minipileup

chmod 755 minipileup

cp -rf minipileup ${PREFIX}/bin

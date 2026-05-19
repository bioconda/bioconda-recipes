#!/bin/bash
set -ex

export CFLAGS="${CFLAGS} -g -Wall -Wno-unused-function -O3"
export CPPFLAGS="${CPPFLAGS} -I${PREFIX}/include"
export LDFLAGS="${LDFLAGS} -L${PREFIX}/lib"

mkdir -p "${PREFIX}/bin"

case "$(uname -m)" in
    x86_64)
        CFLAGS="${CFLAGS} -mavx2"
        make CC="${CC}" CFLAGS="${CFLAGS}" CPPFLAGS="${CPPFLAGS}" LDFLAGS="${LDFLAGS}" -j"${CPU_COUNT}"
        ;;
    arm64|aarch64)
        make arch=arm CC="${CC}" CFLAGS="${CFLAGS}" CPPFLAGS="${CPPFLAGS}" LDFLAGS="${LDFLAGS}" -j"${CPU_COUNT}" ;;
    *)
        echo "Not supported architecture: $(uname -m)" ;;
esac

install -v -m 0755 bwa-fastalign "$PREFIX/bin"

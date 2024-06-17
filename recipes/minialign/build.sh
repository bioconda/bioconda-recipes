#!/bin/bash

set -xe

export CFLAGS="${CFLAGS} -I$PREFIX/include"
export LDFLAGS="${LDFLAGS} -L$PREFIX/lib"
export CPATH=${PREFIX}/include

mkdir -p $PREFIX/bin

case $(uname -m) in
    x86_64)
        ARCH_OPTS="-msse4.2 -mpopcnt"
        ;;
    *)
        ARCH_OPTS="armv8-a"
        ;;
esac

sed -i -e "s/-march=native/${ARCH_OPTS}/g" Makefile
make -j ${CPU_COUNT} CC="${GCC}"
make install PREFIX=$PREFIX


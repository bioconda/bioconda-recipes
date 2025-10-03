#!/bin/bash

export CFLAGS="${CFLAGS} -O3 -I$PREFIX/include -L${PREFIX}/lib"
export LDFLAGS="${LDFLAGS} -L$PREFIX/lib"

mkdir -p "$PREFIX/bin"

sed -i.bak 's|-O4|-O4 -std=gnu11 -I$(PREFIX)/include -L$(PREFIX)/lib -Wno-implicit-function-declaration -Wno-int-conversion|' Makefile
sed -i.bak 's|-lpthread|-pthread|' Makefile

case $(uname -m) in
    aarch64|arm64)
        git clone https://github.com/DLTcollab/sse2neon.git
        cp -f sse2neon/sse2neon.h .
        
        sed -i.bak 's|-mpopcnt -msse4.2||' Makefile
        sed -i.bak 's|#include <emmintrin.h>|#include "sse2neon.h"|' ksw.c
        sed -i.bak 's|#include <emmintrin.h>|#include "sse2neon.h"|' poacns.h
        sed -i.bak 's|#include <tmmintrin.h>||' poacns.h
        ;;
esac

case $(uname -s) in
    "Darwin")
        sed -i.bak 's|-lrt||' Makefile
        ;;
esac
rm -f *.bak

make CC="${CC}"

install -v -m 0755 wtdbg2 wtdbg-cns wtpoa-cns "$PREFIX/bin"

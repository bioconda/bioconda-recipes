#!/bin/bash

export CFLAGS="${CFLAGS} -O3 -I$PREFIX/include -L${PREFIX}/lib"
export LDFLAGS="${LDFLAGS} -L$PREFIX/lib"

mkdir -p "$PREFIX/bin"

sed -i.bak 's|-O4|-O4 -std=gnu11|' Makefile
sed -i.bak 's|-lpthread|-pthread|' Makefile

case $(uname -m) in
    aarch64|arm64)
        sed -i.bak 's|-mpopcnt -msse4.2||' Makefile
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

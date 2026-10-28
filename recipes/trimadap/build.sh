#!/bin/bash

mkdir -p "$PREFIX/bin"

export LDFLAGS="${LDFLAGS} -L${PREFIX}/lib"

make CC="$CC" CFLAGS="${CFLAGS} -g -Wall -O3 -Wno-unused-function -I$PREFIX/include -L$PREFIX/lib"

install -v -m 0755 trimadap-mt "$PREFIX/bin"

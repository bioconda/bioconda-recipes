#!/bin/bash

export CPPFLAGS="${CPPFLAGS} -I${PREFIX}/include"
export LDFLAGS="${LDFLAGS} -L${PREFIX}/lib"
export CFLAGS="${CFLAGS} -O3 -fcommon"

install -d "${PREFIX}/bin"

sed -i.bak 's|-O3|-O3 -std=c99|' Makefile
rm -f *.bak

make CC="${CC}"

install -v -m 0755 SweepFinder2 "${PREFIX}/bin"

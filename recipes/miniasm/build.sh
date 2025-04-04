#!/bin/bash

mkdir -p "${PREFIX}/bin"

export CFLAGS="${CFLAGS} -O3"
export CPPFLAGS="${CPPFLAGS} -I${PREFIX}/include"
export LDFLAGS="${LDFLAGS} -L${PREFIX}/lib"

make CC="${CC}" CFLAGS="${CFLAGS}" CPPFLAGS="${CPPFLAGS}" LIBS="${LDFLAGS} -lm -lz -lpthread"

install -v -m 0755 minidot "${PREFIX}/bin"
install -v -m 0755 miniasm "${PREFIX}/bin"

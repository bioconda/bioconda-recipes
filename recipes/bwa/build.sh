#!/bin/bash

export CFLAGS="${CFLAGS} -g -Wall -Wno-unused-function -O3"
export CPPFLAGS="${CPPFLAGS} -I${PREFIX}/include"
export LDFLAGS="${LDFLAGS} -L${PREFIX}/lib"

mkdir -p "${PREFIX}/bin"
mkdir -p "${PREFIX}/share/man/man1"

make CC="${CC}" CFLAGS="${CFLAGS}" \
	CPPFLAGS="${CPPFLAGS}" LDFLAGS="${LDFLAGS}" \
	-j"${CPU_COUNT}"

install -v -m 0755 bwa xa2multi.pl qualfa2fq.pl "${PREFIX}/bin"
install -v -m 0755 bwa.1 "${PREFIX}/share/man/man1"

#!/bin/bash
set -x -e

mkdir -p "$PREFIX/bin"

export INCLUDE_PATH="${PREFIX}/include"
export LIBRARY_PATH="${PREFIX}/lib"
export LDFLAGS="${LDFLAGS} -L${PREFIX}/lib"
export CPPFLAGS="${CPPFLAGS} -I${PREFIX}/include"
export CXXFLAGS="${CXXFLAGS} -O3 ${LDFLAGS} ${CPPFLAGS}"

cp -f ${PREFIX}/lib/libbam.a standardPregraph/inc/
cp -f ${PREFIX}/lib/libbam.a sparsePregraph/inc/

make SOAPdenovo-63mer
make SOAPdenovo-127mer

install -v -m 0755 SOAPdenovo-127mer "$PREFIX/bin"
install -v -m 0755 SOAPdenovo-63mer "$PREFIX/bin"

cd fusion

make

install -v -m 0755 SOAPdenovo-fusion "$PREFIX/bin"

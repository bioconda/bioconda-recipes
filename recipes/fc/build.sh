#!/bin/bash

export LDFLAGS="$LDFLAGS -L$PREFIX/lib"
export CPATH=${PREFIX}/include
export LIBRARY_PATH=$LIBRARY_PATH:${PREFIX}/lib

make \
  CC="${CXX}" \
  CFLAGS="${CFLAGS} -std=c99"

install -d "${PREFIX}/bin"
install fc-virus "${PREFIX}/bin/"

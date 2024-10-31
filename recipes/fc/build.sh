#!/bin/bash

export LDFLAGS="$LDFLAGS -L$PREFIX/lib"
export CPATH=${PREFIX}/include
export LIBRARY_PATH=$LIBRARY_PATH:${PREFIX}/lib
export C_INCLUDE_PATH=$C_INCLUDE_PATH:${PREFIX}/include

make \
  CXX="${CXX}${CXXFLAGS} ${CPPFLAGS} ${LDFLAGS}" \
  CFLAGS="${CFLAGS} -std=c99"

install -d "${PREFIX}/bin"
install fc-virus "${PREFIX}/bin/"

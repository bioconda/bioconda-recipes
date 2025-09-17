#!/bin/bash

export CPATH="${PREFIX}/include"
export CPLUS_INCLUDE_PATH="${PREFIX}/include"
export LDFLAGS="${LDFLAGS} -L${PREFIX}/lib"
export CFLAGS="${CFLAGS} -O3"

install -d "${PREFIX}/bin"

cd src && make -j"${CPU_COUNT}"

install -v -m 0755 vcfdist "${PREFIX}/bin"

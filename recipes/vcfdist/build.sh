#!/bin/bash

export CPPFLAGS="${CPPFLAGS} -I${PREFIX}/include"
export LDFLAGS="${LDFLAGS} -L${PREFIX}/lib"

install -d "${PREFIX}/bin"

cd src && make -j"${CPU_COUNT}"

install -v -m 0755 vcfdist "${PREFIX}/bin"

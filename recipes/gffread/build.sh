#!/bin/bash

export LDFLAGS="${LDFLAGS} -L${PREFIX}/lib"

mkdir -p "$PREFIX"/bin

make release -j"${CPU_COUNT}" CXX="${CXX}" LINKER="${CXX}"
install -v -m 0755 gffread "${PREFIX}/bin"

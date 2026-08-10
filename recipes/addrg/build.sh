#!/bin/bash

export LDFLAGS="${LDFLAGS} -L${PREFIX}/lib"

mkdir -p "${PREFIX}/bin"

${CC} -o ${PREFIX}/bin/addrg -Wall -O3 addrg.c -I${PREFIX}/include -L${PREFIX}/lib -lhts -lz -pthread

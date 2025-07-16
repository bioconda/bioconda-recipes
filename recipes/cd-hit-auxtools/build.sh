#!/bin/sh
cd cd-hit-auxtools

LFLAGS="${LDFLAGS}" make CC="${CXX}"

mkdir -p "${PREFIX}/bin"
mv \
    cd-hit-dup \
    cd-hit-lap \
    read-linker \
    "${PREFIX}/bin/"

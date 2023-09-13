#!/bin/bash

make CC="${CC}" CPPFLAGS="${CPPFLAGS}" LIBS="${LDFLAGS} -lm -lz -lpthread"

mkdir -p "${PREFIX}/bin"
cp minidot "${PREFIX}/bin/"
cp miniasm "${PREFIX}/bin/"

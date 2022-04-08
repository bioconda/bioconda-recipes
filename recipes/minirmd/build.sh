#!/bin/bash

make CC="${CXX}" CPPFLAGS="${CPPFLAGS}" LIBS="${LDFLAGS} -lm -lz -lpthread"

mkdir -p "${PREFIX}/bin"
cp minirmd "${PREFIX}/bin/"

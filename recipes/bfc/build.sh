#!/bin/bash

LIBS="${LDFLAGS}" make CC="${CC}" CFLAGS="${CFLAGS}" CPPFLAGS="${CPPFLAGS}"

mkdir -p "${PREFIX}/bin"
mv bfc "${PREFIX}/bin/"

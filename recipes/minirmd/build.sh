#!/bin/bash

make CC="${CC}" CPPFLAGS="${CPPFLAGS}" LIBS="-lz -lpthread"

mkdir -p "${PREFIX}/bin"
cp minirmd "${PREFIX}/bin/"

#!/bin/bash
set -euxo pipefail

export LDFLAGS="${LDFLAGS} -L${PREFIX}/lib"
export CPPFLAGS="${CPPFLAGS} -I${PREFIX}/include"

sed -i.bak 's|-O3|-O3 -Wno-deprecated-declarations -Wno-implicit-function-declaration|' src/Makefile

cd src

if [[ "$target_platform" == 'linux-aarch64' ]]; then
  sed -i '1i#include <math.h>' ic.c
  sed -i '1i#include <math.h>' ic_mes.c
  sed -i '1i#include <math.h>' ic_mep.c
  sed -i 's|http:\\/\\/|http://|g' ic_mep.c
  make all CC="${CC}" CCMPI="mpicc" LDFLAGS="${LDFLAGS} -lm" -j"${CPU_COUNT}"
else
  make all CC="${CC}" CCMPI="mpicc" -j"${CPU_COUNT}"
fi

chmod +x ../bin/*
cp -pr ../bin "$PREFIX"

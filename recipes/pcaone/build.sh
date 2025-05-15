#!/bin/bash

mkdir -p ${PREFIX}/bin
# fix zlib issue
export CFLAGS="${CFLAGS} -O3"
export CPPFLAGS="${CPPFLAGS} -O3 -I${PREFIX}/include"
export CXXFLAGS="${CXXFLAGS} -O3"
export LDFLAGS="${LDFLAGS} -L${PREFIX}/lib"

sed -i.bak 's|-lpthread|-pthread|' Makefile

if [[ $(uname -s) == "Linux" ]]; then
  make clean && make CXX="${CXX}" MKLROOT="${PREFIX}" AVX=0 -j"${CPU_COUNT}" STATIC=1 && mv PCAone "${PREFIX}/bin/PCAone.x64"
  make clean && make CXX="${CXX}" MKLROOT="${PREFIX}" AVX=1 -j"${CPU_COUNT}" STATIC=1 && mv PCAone "${PREFIX}/bin/PCAone.avx2"
  cp -f "${PREFIX}/bin/PCAone.avx2" "${PREFIX}/bin/PCAone.avx22"
  export LDFLAGS="${LDFLAGS} -Wl,--no-as-needed -L${PREFIX}/lib"
  echo "#!/usr/bin/env bash
  PCAone=${PREFIX}/bin/PCAone.avx2
  grep avx2 /proc/cpuinfo |grep fma &>/dev/null
  [[ \$? != 0 ]] && PCAone=${PREFIX}/bin/PCAone.x64
  exec \$PCAone \$@" > ${PREFIX}/bin/PCAone && chmod 0755 ${PREFIX}/bin/PCAone
  mv "${PREFIX}/bin/PCAone.avx22" "${PREFIX}/bin/PCAone.avx2"
elif [[ $(uname -s) == "Darwin" ]]; then
  make MKLROOT="${PREFIX}" -j"${CPU_COUNT}"
  install -v -m 0755 PCAone ${PREFIX}/bin
fi

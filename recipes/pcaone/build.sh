#!/bin/bash

mkdir -p ${PREFIX}/bin
# fix zlib issue
export CFLAGS="${CFLAGS} -O3"
export CPPFLAGS="${CPPFLAGS} -O3 -I${PREFIX}/include"
export CXXFLAGS="${CXXFLAGS} -O3"
export LDFLAGS="${LDFLAGS} -L$PREFIX/lib"

if [[ $(uname -s) == "Linux" ]]; then
  make clean && make MKLROOT="${PREFIX}" AVX=0 -j"${CPU_COUNT}" && mv PCAone "${PREFIX}/bin/PCAone.x64"
  make clean && make MKLROOT="${PREFIX}" AVX=1 -j"${CPU_COUNT}" && mv PCAone "${PREFIX}/bin/PCAone.avx2"
  export LDFLAGS="${LDFLAGS} -Wl,--no-as-needed -L${PREFIX}/lib"
  echo "#!/usr/bin/env bash
PCAone=${PREFIX}/bin/PCAone.avx2
grep avx2 /proc/cpuinfo |grep fma &>/dev/null
[[ \$? != 0 ]] && PCAone=${PREFIX}/bin/PCAone.x64
exec \$PCAone \$@" > ${PREFIX}/bin/PCAone && chmod 0755 ${PREFIX}/bin/PCAone

elif [[ $(uname -s) == "Darwin" ]]; then
  make MKLROOT="${PREFIX}" -j"${CPU_COUNT}"
  install -v -m 0755 PCAone ${PREFIX}/bin
fi

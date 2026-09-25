#!/bin/bash
set -eu -o pipefail
set -x

# The htslib dependency caused odd problems in bioconda build
# pkg-config works on linux, but still need to have additional libraries
# in meta.yaml. It doesn't work on MacOS, So try both pkg-config and --with-htslib.
export PKG_CONFIG_PATH=${PREFIX}/lib/pkgconfig:${PKG_CONFIG_PATH:-}
export CPPFLAGS="${CPPFLAGS} -I${PREFIX}/include"
export LDFLAGS="${LDFLAGS} -L${PREFIX}/lib"

./configure --prefix="${PREFIX}" --with-htslib=${PREFIX} \
  CXX="${CXX}" LDFLAGS="${LDFLAGS}" CPPFLAGS="${CPPFLAGS}" \
  CXXFLAGS="${CXXFLAGS}" || { cat config.log; exit 1; }
make -j"${CPU_COUNT}"
make install

echo @@@@@@@@@@@@ ${PREFIX}  @@@@@@@@@@@@
ls ${PREFIX}
cat Makefile
echo @@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@

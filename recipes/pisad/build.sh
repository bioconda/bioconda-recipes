#!/bin/bash -euo

set -xe

OS=$(uname)
ARCH=$(uname -m)

export M4="${BUILD_PREFIX}/bin/m4"
export CFLAGS="${CFLAGS} -I$PREFIX/include -O3"
export LDFLAGS="${LDFLAGS} -L$PREFIX/lib"
export CPATH="${PREFIX}/include"
export CXXFLAGS="${CXXFLAGS} -I${PREFIX}/include -O3 -std=c++17 -Wno-braced-scalar-init"
export CPPFLAGS="${CPPFLAGS} -I${PREFIX}/include"

if [[ "${OS}" == "Darwin" && "${ARCH}" == "arm64" ]]; then
  export EXTRA_ARGS="--host=arm64"
elif [[ "${OS}" == "Linux" && "${ARCH}" == "aarch64" ]]; then
  export EXTRA_ARGS="--host=aarch64"
else
  export EXTRA_ARGS="--host=x86_64"
fi

autoreconf -if
./configure --prefix="${PREFIX}" CC="${CC}" CXX="${CXX}" \
  CFLAGS="${CFLAGS}" CXXFLAGS="${CXXFLAGS}" \
  CPPFLAGS="${CPPFLAGS}" LDFLAGS="${LDFLAGS}" \
  --disable-dependency-tracking --disable-silent-rules "${EXTRA_ARGS}"

make -j ${CPU_COUNT}
make install

mkdir -p ${PREFIX}/bin
cp -rf snpcalling/kcov.py ${PREFIX}/bin
cp -rf snpcalling/run.sh ${PREFIX}/bin

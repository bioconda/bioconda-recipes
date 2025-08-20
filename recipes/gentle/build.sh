#!/bin/bash
set -ex

mkdir -p "${PREFIX}"

export LDFLAGS="${LDFLAGS} -L${PREFIX}/lib"
export CPPFLAGS="${CPPFLAGS} -I${PREFIX}/include"
export CFLAGS="${CFLAGS} -O3"
export CXXFLAGS="${CXXFLAGS} -O3 -I${PREFIX}/include"

cp -rf ${BUILD_PREFIX}/share/gnuconfig/config.* .
cp -rf ${BUILD_PREFIX}/share/gnuconfig/config.* m4/

OS=$(uname -s)
ARCH=$(uname -m)

if [[ "${OS}" == "Darwin" && "${ARCH}" == "arm64" ]]; then
	export EXTRA_ARGS="--host=arm64"
elif [[ "${OS}" == "Linux" && "${ARCH}" == "aarch64" ]]; then
	export EXTRA_ARGS="--host=aarch64"
else
	export EXTRA_ARGS="--host=x86_64"
fi

./autogen.sh
./configure --prefix="${PREFIX}" \
	CXX="${CXX}" CXXFLAGS="${CXXFLAGS}" \
	CPPFLAGS="${CPPFLAGS}" LDFLAGS="${LDFLAGS}" \
	CC="${CC}" CFLAGS="${CFLAGS}" \
	--disable-option-checking --enable-silent-rules \
	--disable-dependency-tracking --with-clustalw=yes \
	"${EXTRA_ARGS}"

make -j"${CPU_COUNT}"
make install

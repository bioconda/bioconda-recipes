#!/bin/bash
set -xe

export LDFLAGS="${LDFLAGS} -L${PREFIX}/lib"
export CPPFLAGS="${CPPFLAGS} -I${PREFIX}/include"
export CFLAGS="${CFLAGS} -O3"
export CXXFLAGS="${CXXFLAGS} -O3"
export LC_ALL="en_US.UTF-8"

ROOT=`pwd -P`
[ -z "${DEST}" ] && DEST="${ROOT}"

###################
# Check for gmake #
###################
mkdir -p dist-bin
PATH="${PATH}:${ROOT}/dist-bin"
ln -sf $(which make) "${ROOT}/dist-bin/gmake"
ln -sf "${ROOT}/PkgConfig.pm" "${ROOT}/dist-bin/pkg-config"

BINDIR="${PREFIX}/bin"
LIBDIR="${PREFIX}/lib"
export PKG_CONFIG_PATH="${LIBDIR}/pkgconfig:${PKG_CONFIG_PATH}"

cd global-1
autoreconf -if
./configure --prefix="${PREFIX}" --bindir="${BINDIR}" --libdir="${LIBDIR}" \
	--enable-silent-rules --disable-option-checking --disable-dependency-tracking \
	CC="${CC}" CXX="${CXX}" CPPFLAGS="${CPPFLAGS}" LDFLAGS="${LDFLAGS}" \
	CFLAGS="${CFLAGS}" CXXFLAGS="${CXXFLAGS}" && \
make install-special -j"${CPU_COUNT}" && \
cd ${PREFIX}/bin && \
	tar -xzf TransDecoder-v5.7.1a.tar.gz && \
	rm -rf TransDecoder-v5.7.1a.tar.gz

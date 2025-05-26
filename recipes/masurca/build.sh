#!/bin/bash
set -xe

export PERL_EXT_CPPFLAGS="-D_REENTRANT -D_GNU_SOURCE -fwrapv -fno-strict-aliasing -pipe -fstack-protector"
export PERL_EXT_LDFLAGS="-shared -O3 -fstack-protector"
export LIBRARY_PATH="${PREFIX}/lib"
export INCLUDE_PATH="${PREFIX}/include"
export LDFLAGS="${LDFLAGS} -L${PREFIX}/lib"
export CPATH="${PREFIX}/include"
export CPPFLAGS="${CPPFLAGS} -I${PREFIX}/include"
export CFLAGS="${CFLAGS} -O3 -std=gnu11"
export CXXFLAGS="${CXXFLAGS} -O3 -std=c++14 -Wno-use-after-free -Wno-misleading-indentation -Wno-unused-result"
export LC_ALL="en_US.UTF-8"

sed -i.bak 's|-O2|-O3|' Flye/lib/minimap2/Makefile
sed -i.bak 's|-lpthread|-pthread|' Flye/lib/minimap2/Makefile
rm -rf Flye/lib/minimap2/*.bak

ROOT=`pwd -P`
[ -z "${DEST}" ] && DEST="${ROOT}"

###################
# Check for gmake #
###################
mkdir -p dist-bin
PATH="${PATH}:${ROOT}/dist-bin"
ln -sf $(which make) "${ROOT}/dist-bin/gmake"
ln -sf "${ROOT}/PkgConfig.pm" "${ROOT}/dist-bin/pkg-config"

export NUM_THREADS=`grep -c '^processor' /proc/cpuinfo 2>/dev/null || sysctl -n hw.ncpu 2>/dev/null || echo 1`;
BINDIR="${PREFIX}/bin"
LIBDIR="${PREFIX}/lib"
export PKG_CONFIG_PATH="${LIBDIR}/pkgconfig:${PKG_CONFIG_PATH}"

cd global-1

autoreconf -if
./configure --prefix="${PREFIX}" --bindir="${BINDIR}" --libdir="${LIBDIR}" \
	--enable-silent-rules --disable-option-checking --disable-dependency-tracking \
	CC="${CC}" CXX="${CXX}" CPPFLAGS="${CPPFLAGS}" LDFLAGS="${LDFLAGS}" \
	CFLAGS="${CFLAGS}" CXXFLAGS="${CXXFLAGS}" BOOST_ROOT="${PREFIX}"
make install-special -j"${CPU_COUNT}"

echo "Creating example config file masurca_config_example.txt:"
${BINDIR}/masurca -g masurca_config_example.txt

cd ${SRC_DIR}/Flye
make -j"${CPU_COUNT}"
install -v -m 0755 bin/flye* "${PREFIX}/bin"

#!/bin/bash
set -ex

export MEME_ETC_DIR="${PREFIX}/etc"
export INCLUDE_PATH="${PREFIX}/include"
export LIBRARY_PATH="${PREFIX}/lib"
export LDFLAGS="${LDFLAGS} -L${PREFIX}/lib"
export CPPFLAGS="${CPPFLAGS} -I${PREFIX}/include"
export CFLAGS="${CFLAGS} -O3"
export LC_ALL="en_US.UTF-8"

autoreconf -if
./configure --prefix="${PREFIX}" \
	CC="${CC}" \
	CFLAGS="${CFLAGS}" \
	LDFLAGS="${LDFLAGS}" \
	CPPFLAGS="${CPPFLAGS}" \
	--enable-build-libxml2 --enable-build-libxslt \
	--disable-option-checking --enable-silent-rules --disable-dependency-tracking

make AM_CFLAGS='-DNAN="(0.0/0.0)"' -j"${CPU_COUNT}"
make install
make clean

ln -sf ${PREFIX}/libexec/${PKG_NAME}-${PKG_VERSION}/* ${PREFIX}/bin/

# if building with python3,
# modify meme-chip script to use python3 version of DREME
if [[ ${PY3K}==1 ]]; then
	sed -i.bak '994s/dreme/dreme-py3/' ${PREFIX}/bin/meme-chip
	rm -f ${PREFIX}/bin/meme-chip.bak
	# Fix for dreme
	install -v -m 0755 scripts/*py3.py "${PREFIX}/lib/${PKG_NAME}-${PKG_VERSION}/python"
fi

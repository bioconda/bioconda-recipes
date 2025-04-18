#!/bin/bash -ex

export MEME_ETC_DIR="${PREFIX}/etc"
export INCLUDE_PATH="${PREFIX}/include"
export LIBRARY_PATH="${PREFIX}/lib"

autoreconf -if

./configure CC="${CC}" \
	CFLAGS="${CFLAGS} -O3 -I${PREFIX}/include" \
	LDFLAGS="${LDFLAGS} -L${PREFIX}/lib" \
	--prefix="${PREFIX}" \
	--enable-build-libxml2 \
	--enable-build-libxslt

make AM_CFLAGS='-DNAN="(0.0/0.0)"' -j"${CPU_COUNT}"
make install
make clean

ln -sf ${PREFIX}/libexec/${PKG_NAME}-${PKG_VERSION}/* ${PREFIX}/bin/

# if building with python3,
# modify meme-chip script to use python3 version of DREME
if [ ${PY3K}==1 ]; then
	sed -i.bak  '994s/dreme/dreme-py3/' ${PREFIX}/bin/meme-chip
	rm ${PREFIX}/bin/meme-chip.bak
	# Fix for dreme
	cp -rf scripts/*py3.py ${PREFIX}/lib/${PKG_NAME}-${PKG_VERSION}/python/
fi

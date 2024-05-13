#!/bin/bash
set -e

export MEME_ETC_DIR=${PREFIX}/etc
#HOME=/tmp cpanm CGI::Application
#HOME=/tmp cpanm XML::Parser::Expat --configure-args "EXPATLIBPATH=$PREFIX/lib" --configure-args "EXPATHINCPATH=$PREFIX/include"

autoreconf -i

perl scripts/dependencies.pl

./configure CC="${CC}" \
	CFLAGS="${CFLAGS} -O3 -I${PREFIX}/include" \
	LDFLAGS="${LDFLAGS} -L${PREFIX}/lib" \
	--prefix="${PREFIX}" \
	--enable-build-libxml2 \
	--enable-build-libxslt

make AM_CFLAGS='-DNAN="(0.0/0.0)"' -j4

# tests will only work inside the build dir, but
# https://github.com/conda/conda-build/issues/1453
# so you need `conda build --prefix-length 1`
# for it to work properly
# make test

make install
make clean

ln -sf ${PREFIX}/libexec/${PKG_NAME}-${PKG_VERSION}/* ${PREFIX}/bin/

# if building with python3,
# modify meme-chip script to use python3 version of DREME
if [ ${PY3K}==1 ]; then
	sed -i.bak  '994s/dreme/dreme-py3/' ${PREFIX}/bin/meme-chip
	rm ${PREFIX}/bin/meme-chip.bak
	# Fix for dreme
	cp scripts/*py3.py ${PREFIX}/lib/${PKG_NAME}-${PKG_VERSION}/python/
fi


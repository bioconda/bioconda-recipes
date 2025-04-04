#!/bin/bash
set -e
MEME_ETC_DIR=${PREFIX}/etc
#HOME=/tmp cpanm CGI::Application
#HOME=/tmp cpanm XML::Parser::Expat --configure-args "EXPATLIBPATH=$PREFIX/lib" --configure-args "EXPATHINCPATH=$PREFIX/include"
#perl scripts/dependencies.pl

./configure --prefix="$PREFIX"

if [[ ${target_platform} =~ osx.* ]] ; then
	export LDFLAGS="${LDFLAGS}"
	export CFLAGS="${CFLAGS} -fcommon -fgnu89-inline"
else
	export LDFLAGS="${LDFLAGS} -Wl,--allow-multiple-definition"
	export CFLAGS="${CFLAGS} -fcommon -fgnu89-inline"
fi

make clean
make AM_CFLAGS="-DNAN='(0.0/0.0)'" CFLAGS="$CFLAGS" LDFLAGS="$LDFLAGS"

# tests will only work inside the build dir, but
# https://github.com/conda/conda-build/issues/1453
# so you need `conda build --prefix-length 1`
# for it to work properly
# make test

make install

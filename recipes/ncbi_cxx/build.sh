#!/bin/bash
set -euxo pipefail

export CFLAGS="$CFLAGS -O2"
export CXXFLAGS="$CXXFLAGS -O2"
export CPPFLAGS="$CPPFLAGS -I$PREFIX/include"
export LDFLAGS="$LDFLAGS -L$PREFIX/lib"
export CC_FOR_BUILD=$CC

if test x"`uname`" = x"Linux"; then
    # only add things needed; not supported by OSX ld
    LDFLAGS="$LDFLAGS -Wl,-as-needed"
fi

if [ `uname` == Darwin ]; then
    export LDFLAGS="${LDFLAGS} -Wl,-rpath,$PREFIX/lib -lz -lbz2 -lomp"
else
    export CPP_FOR_BUILD=$CPP
fi

LIB_INSTALL_DIR=$PREFIX/lib/ncbi_cxx

./configure \
    --with-dll \
    --with-mt \
    --with-openmp \
    --without-autodep \
    --without-makefile-auto-update \
    --with-flat-makefile \
    --without-caution \
    --without-lzo \
    --with-hard-runpath \
    --with-runpath=$LIB_INSTALL_DIR \
    --without-debug \
    --with-strip \
    --without-vdb \
    --with-z=$PREFIX \
    --with-bz2=$PREFIX \
    --without-krb5 \
    --without-openssl \
    --without-gnutls \
    --without-sse42 \
    --without-gcrypt

make --debug=j -j${CPU_COUNT} -f Makefile

find .

mkdir -p $PREFIX/bin 

#extra log to check all exe are present
ls -s $PREFIX/bin/

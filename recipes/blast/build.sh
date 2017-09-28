#!/bin/bash

set -e -x -o pipefail

cd $SRC_DIR/c++/

export CFLAGS="$CFLAGS -O2"
export CXXFLAGS="$CXXFLAGS -O2"
export CPPFLAGS="$CPPFLAGS -I$PREFIX/include"
export LDFLAGS="$LDFLAGS -L$PREFIX/lib"

if test x"`uname`" = x"Linux"; then
    # only add things needed; not supported by OSX ld
    LDFLAGS="$LDFLAGS -Wl,-as-needed"
fi

# --with-hard-runpath is needed otherwise BLAST programs would search
# libraries first in the directories defined by the LD_LIBRARY_PATH
# environment variable, instead of using the rpath specified by conda

./configure \
    --with-dll \
    --with-mt \
    --without-autodep \
    --without-makefile-auto-update \
    --with-flat-makefile \
    --without-caution \
    --without-dbapi \
    --without-lzo \
    --with-hard-runpath \
    --without-debug \
    --with-strip \
    --without-vdb \
    --with-z=$PREFIX \
    --with-bz2=$PREFIX \
    --with-boost=$PREFIX \
    --without-openssl \
    --without-gcrypt \
    --with-gnutls=$PREFIX \
    --with-nettle=$PREFIX \
    --without-krb5

projects="algo/blast/ app/ objmgr/ objtools/align_format/ objtools/blast/"

cd */build

make -j${CPU_COUNT} -f Makefile.flat all_projects="$projects"

mkdir -p $PREFIX/{bin,lib,include}
cp $SRC_DIR/c++/ReleaseMT/bin/* $PREFIX/bin/
cp $SRC_DIR/c++/ReleaseMT/lib/* $PREFIX/lib/

chmod +x $PREFIX/bin/*

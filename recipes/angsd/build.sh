#! /bin/bash

mkdir -p ${PREFIX}/bin

# INSTALL_PROGRAM: misc/Makefile uses 'install -D', which BSD install on macOS rejects
# '-D__STDC_FORMAT_MACROS' fix from https://github.com/ANGSD/angsd/issues/397
make HTSSRC="systemwide" CFLAGS="$CFLAGS" CPPFLAGS="$CPPFLAGS" prefix=$PREFIX \
 CC="$CC" CXX="$CXX" FLAGS="-I${PREFIX}/include -L${PREFIX}/lib -D__STDC_FORMAT_MACROS" \
 INSTALL_PROGRAM="install -m0755" install-all

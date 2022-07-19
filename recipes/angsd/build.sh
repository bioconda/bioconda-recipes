#! /bin/bash

mkdir -p ${PREFIX}/bin

# '-D__STDC_FORMAT_MACROS' fix from https://github.com/ANGSD/angsd/issues/397
make HTSSRC="systemwide" CFLAGS="$CFLAGS" CPPFLAGS="$CPPFLAGS" prefix=$PREFIX \
 CC="$CC" CXX="$CXX" FLAGS="-I${PREFIX}/include -L${PREFIX}/lib -D__STDC_FORMAT_MACROS" \
 install-all

#! /bin/bash

mkdir -p ${PREFIX}/bin

# FLAGS is used on the link lines (angsd and misc/), so it carries $LDFLAGS
# (incl. -headerpad_max_install_names, needed on macOS) and -O3 for misc/.
# INSTALL_PROGRAM: misc/Makefile uses 'install -D', which BSD install on macOS rejects
# '-D__STDC_FORMAT_MACROS' fix from https://github.com/ANGSD/angsd/issues/397
make HTSSRC="systemwide" CFLAGS="$CFLAGS" CPPFLAGS="$CPPFLAGS" prefix=$PREFIX \
 CC="$CC" CXX="$CXX" FLAGS="-O3 -I${PREFIX}/include ${LDFLAGS} -D__STDC_FORMAT_MACROS" \
 INSTALL_PROGRAM="install -m0755" install-all

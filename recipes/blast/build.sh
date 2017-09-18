#!/bin/bash

set -e -x -o pipefail

cd $SRC_DIR/c++/

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
    --without-downloaded-vdb \
    --with-z=$PREFIX \
    --with-bz2=$PREFIX \
    --with-openssl=$PREFIX \
    --with-boost=$PREFIX \
    --with-openssl=$PREFIX

projects="algo/blast/ app/ objmgr/ objtools/align_format/ objtools/blast/"

cd */build

make -j${CPU_COUNT} -f Makefile.flat all_projects="$projects"

mkdir -p $PREFIX/{bin,lib,include}
cp $SRC_DIR/c++/ReleaseMT/bin/* $PREFIX/bin/
cp $SRC_DIR/c++/ReleaseMT/lib/* $PREFIX/lib/

chmod +x $PREFIX/bin/*

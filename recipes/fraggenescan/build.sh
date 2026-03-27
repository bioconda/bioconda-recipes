#!/bin/bash
set -xe

export LDFLAGS="${LDFLAGS} -L${PREFIX}/lib"
export CFLAGS="${CFLAGS} -O3"

mkdir -p "$PREFIX/bin"

make clean  # There are .o files in the tarball!
make CC="${CC}" -j"${CPU_COUNT}"
make fgs CC="${CC}" -j"${CPU_COUNT}"

sed -i.bak '1 s|^.*$|#!/usr/bin/env perl|g' $SRC_DIR/run_FragGeneScan.pl
rm -f *.bak
chmod a+x $SRC_DIR/*FragGeneScan*

install -v -m 0755 $SRC_DIR/FragGeneScan $SRC_DIR/run_FragGeneScan.pl "$PREFIX/bin"
cp -rf $SRC_DIR/train $PREFIX/bin/

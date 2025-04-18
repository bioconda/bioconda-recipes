#!/bin/bash

set -xe

mkdir -p $PREFIX/bin/

make clean  # There are .o files in the tarball!
make CC=${CC} -j ${CPU_COUNT}
make fgs CC=${CC} -j ${CPU_COUNT}

sed -i.bak '1 s|^.*$|#!/usr/bin/env perl|g' $SRC_DIR/run_FragGeneScan.pl
chmod a+x $SRC_DIR/*FragGeneScan*

cp $SRC_DIR/FragGeneScan $PREFIX/bin/
cp $SRC_DIR/run_FragGeneScan.pl $PREFIX/bin/
cp -r $SRC_DIR/train $PREFIX/bin/

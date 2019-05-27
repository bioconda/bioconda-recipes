#!/bin/bash

mkdir -p $PREFIX/bin/

make clean  # There are .o files in the tarball!
make CC=${CC}
make fgs CC=${CC}

sed -i.bak '1 s|^.*$|#!/usr/bin/env perl|g' $SRC_DIR/run_FragGeneScan.pl
chmod a+x $SRC_DIR/*FragGeneScan*

cp $SRC_DIR/FragGeneScan $PREFIX/bin/
cp $SRC_DIR/run_FragGeneScan.pl $PREFIX/bin/
cp -r $SRC_DIR/train $PREFIX/bin/

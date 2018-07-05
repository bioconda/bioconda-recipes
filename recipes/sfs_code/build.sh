#!/bin/bash
make
mkdir -p $PREFIX/bin
cp $SRC_DIR/bin/sfs_code $PREFIX/bin/sfs_code
cp $SRC_DIR/bin/convertSFS_CODE $PREFIX/bin/convertSFS_CODE

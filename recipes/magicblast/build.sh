#!/bin/bash

set -e -x -o pipefail

mkdir -p $PREFIX/bin/

chmod +x $SRC_DIR/bin/*

cp $SRC_DIR/bin/makeblastdb $PREFIX/bin/magicblast-makeblastdb
cp $SRC_DIR/bin/magicblast $PREFIX/bin/magicblast

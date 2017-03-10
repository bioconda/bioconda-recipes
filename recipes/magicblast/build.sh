#!/bin/bash

set -e -x -o pipefail

mkdir -p $PREFIX/bin/

chmod +x $SRC_DIR/bin/*
mv $SRC_DIR/bin/makeblastdb $SRC_DIR/bin/magicblast-makeblastdb
cp $SRC_DIR/bin/* $PREFIX/bin/

#!/bin/sh
set -x -e
mkdir -p ${PREFIX}/bin
ls $SRC_DIR 
cp -rf $SRC_DIR/TEtrimmer-main/tetrimmer ${PREFIX}/bin
cd ${PREFIX}/bin/tetrimmer

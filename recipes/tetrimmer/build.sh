#!/bin/sh
set -x -e
mkdir -p ${PREFIX}/bin
cp -r $SRC_DIR/tetrimmer ${PREFIX}/bin
cd ${PREFIX}/bin/tetrimmer

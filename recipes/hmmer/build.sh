#!/bin/sh

set -e -u -x

./configure --prefix=$PREFIX
make -j4
make install
(cd "${SRC_DIR}/easel" && make install)

# keep easel lib for other rcipes (e.g sfld)
mkdir -p $PREFIX/share
rm -rf ${SRC_DIR}/easel/miniapps
cp -r ${SRC_DIR}/easel $PREFIX/share/


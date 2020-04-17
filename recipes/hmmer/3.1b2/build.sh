#!/bin/sh

set -e -u -x

# Fix broken configure option
sed -i.bak -e 's/acx_maxopt_portable=$withval/acx_maxopt_portable=$enableval/' configure

./configure --enable-portable-binary  --prefix=$PREFIX
make -j4
make install
(cd "${SRC_DIR}/easel" && make install PREFIX=$PREFIX)

# keep easel lib for other rcipes (e.g sfld)
mkdir -p $PREFIX/share
rm -rf ${SRC_DIR}/easel/miniapps
cp -r ${SRC_DIR}/easel $PREFIX/share/

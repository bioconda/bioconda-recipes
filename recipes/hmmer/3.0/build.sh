#!/bin/sh

set -e -u -x

./configure --prefix=$PREFIX
make -j4
make install
(cd "${SRC_DIR}/easel" && make install PREFIX=$PREFIX)

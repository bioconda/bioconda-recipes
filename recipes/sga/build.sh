#!/bin/bash
set -x
set -e

pushd $SRC_DIR/src
bamtools=$(conda list bamtools -c)
./autogen.sh
./configure --prefix=$PREFIX --with-bamtools=$SYS_PREFIX/pkgs/$bamtools  && make && make install

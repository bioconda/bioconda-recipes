#!/bin/bash
set -x
set -e

pushd $SRC_DIR/src
bamtools=$(conda list bamtools -c | awk -F'::' '{print $2}')
./autogen.sh
./configure --prefix=$PREFIX --with-bamtools=$SYS_PREFIX/pkgs/$bamtools  && make && make install

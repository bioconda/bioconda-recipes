#!/usr/bin/env bash

set -xe

export LC_ALL=C.UTF-8
export LANG=C.UTF-8

mkdir -p $PREFIX/bin 
cp -rf STITCH.R $PREFIX/bin

cd $SRC_DIR/STITCH
${R} CMD INSTALL --build --install-tests . ${R_ARGS}

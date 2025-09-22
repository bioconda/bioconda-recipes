#!/usr/bin/env bash
set -xe

export DISABLE_AUTOBREW=1
export LC_ALL="en_US.UTF-8"

mkdir -p "$PREFIX/bin"

cp -rf STITCH.R $PREFIX/bin

cd $SRC_DIR/STITCH

${R} CMD INSTALL --build --install-tests . "${R_ARGS}"

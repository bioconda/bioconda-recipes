#!/bin/bash

set -xe

mkdir -p $PREFIX/bin

export LC_ALL=C.UTF-8
export LANG=C.UTF-8

cp -rf $SRC_DIR/QUILT.R $PREFIX/bin/
cp -rf $SRC_DIR/QUILT_prepare_reference.R $PREFIX/bin/
cp -rf $SRC_DIR/QUILT_HLA_prepare_reference.R $PREFIX/bin/
cp -rf $SRC_DIR/QUILT2.R $PREFIX/bin/
cp -rf $SRC_DIR/QUILT2_prepare_reference.R $PREFIX/bin/

cd $SRC_DIR/QUILT
${R} CMD INSTALL --build --install-tests . ${R_ARGS}

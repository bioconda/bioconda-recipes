#!/bin/bash

set -xe

export LC_ALL=C.UTF-8
export LANG=C.UTF-8

cp $SRC_DIR/QUILT.R $PREFIX/bin/
cp $SRC_DIR/QUILT_prepare_reference.R $PREFIX/bin/
cp $SRC_DIR/QUILT_HLA_prepare_reference.R $PREFIX/bin/
cp $SRC_DIR/QUILT2.R $PREFIX/bin/
cp $SRC_DIR/QUILT2_prepare_reference.R $PREFIX/bin/

cd $SRC_DIR/QUILT
${R} CMD INSTALL --build --install-tests .


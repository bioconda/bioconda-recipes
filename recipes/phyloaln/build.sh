#!/bin/bash

set -xe

mkdir -p $PREFIX/bin
cp -rf $SRC_DIR/lib $PREFIX/bin
cp $SRC_DIR/PhyloAln $PREFIX/bin
cp -rf $SRC_DIR/scripts/* $PREFIX/bin

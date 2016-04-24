#!/bin/bash
mkdir -p $PREFIX/bin
cp $SRC_DIR/export2graphlan.py $PREFIX/bin

mkdir -p $PREFIX/bin/hclust2
cp $SRC_DIR/hclust2/hclust2.py $PREFIX/bin/hclust2
cp $SRC_DIR/hclust2/__init__.py $PREFIX/bin/hclust2
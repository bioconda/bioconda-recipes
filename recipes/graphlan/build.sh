#!/bin/bash
mkdir -p $PREFIX/bin
cp $SRC_DIR/graphlan.py $PREFIX/bin
cp $SRC_DIR/graphlan_annotate.py $PREFIX/bin
cp -r $SRC_DIR/src $PREFIX/bin/
cp -r $SRC_DIR/export2graphlan $PREFIX/bin
cp -r $SRC_DIR/pyphlan $PREFIX/bin

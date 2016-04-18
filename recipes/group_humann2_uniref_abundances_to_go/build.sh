#!/bin/bash

mkdir -p $PREFIX/bin/
cp $SRC_DIR/download_datasets.sh $PREFIX/bin/
cp $SRC_DIR/group_to_GO_abundances.sh $PREFIX/bin/
chmod +x $PREFIX/bin/*

cp -r $SRC_DIR/src $PREFIX/bin/src

cp -r $SRC_DIR/test-data $PREFIX/bin/test-data
#!/bin/bash

mkdir -p $PREFIX/bin/
cp $SRC_DIR/group_humann2_uniref_abundances_to_GO.sh $PREFIX/bin/
chmod +x $PREFIX/bin/*

cp -r $SRC_DIR/src $PREFIX/bin/src


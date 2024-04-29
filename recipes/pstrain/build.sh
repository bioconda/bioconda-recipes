#!/bin/bash

make 

mkdir -p $PREFIX/bin

cp $SRC_DIR/scripts/*py $PREFIX/bin
cp $SRC_DIR/scripts/*sh $PREFIX/bin
cp $SRC_DIR/scripts/*jar $PREFIX/bin


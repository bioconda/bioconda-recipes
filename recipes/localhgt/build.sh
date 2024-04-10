#!/bin/bash

# Ensure we run successfully using either conda-forge or defaults ncurses
# (unlike other platforms, the latter does not automatically pull in libtinfo)
make 

mkdir -p $PREFIX/bin

cp $SRC_DIR/scripts/*py $PREFIX/bin
cp $SRC_DIR/scripts/*sh $PREFIX/bin
cp $SRC_DIR/scripts/extract_ref $PREFIX/bin

#!/bin/bash

# cd to location of Makefile and source
#cd $SRC_DIR/src

# export PRFX=$PREFIX
# make

ls $SRC_DIR

binaries="\
srprism \
"
#chmod +x $SRC_DIR/srprism
#$SRC_DIR/srprism
#exit 1

mkdir -p $PREFIX/bin
for i in $binaries; do cp $SRC_DIR/$i $PREFIX/bin/ && chmod +x $PREFIX/bin/$i; done

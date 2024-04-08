#!/bin/bash

export C_INCLUDE_PATH=${PREFIX}/include
export LIBRARY_PATH=${PREFIX}/lib

make CFLAGS="${CFLAGS} -fcommon"

# make
mkdir -p $PREFIX/bin
cp $SRC_DIR/*py $PREFIX/bin
cp $SRC_DIR/*sh $PREFIX/bin
cp $SRC_DIR/extract_ref $PREFIX/bin

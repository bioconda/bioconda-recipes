#!/bin/bash
set -eu -o pipefail

mkdir -p $PREFIX/bin


#export CPLUS_INCLUDE_PATH="${PREFIX}/include"
#export LIBRARY_PATH="${PREFIX}/lib"
#export LDFLAGS="${LDFLAGS} -L${PREFIX}/lib"

#make CC="${GXX}" CFLAGS="${CFLAGS}"
#make CC="${GXX} ${LDFLAGS}" CFLAGS="${CFLAGS}"

make

cp $SRC_DIR/scripts/*py $PREFIX/bin
cp $SRC_DIR/scripts/*sh $PREFIX/bin
cp $SRC_DIR/scripts/extract_ref $PREFIX/bin

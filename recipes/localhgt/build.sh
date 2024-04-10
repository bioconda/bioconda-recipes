#!/bin/bash
set -eu -o pipefail

export LIBRARY_PATH=${PREFIX}/lib
export LD_LIBRARY_PATH=${PREFIX}/lib
export CPP_INCLUDE_PATH=${PREFIX}/include
export CPLUS_INCLUDE_PATH=${PREFIX}/include
export CXX_INCLUDE_PATH=${PREFIX}/include


mkdir -p $PREFIX/bin



make
#make CC="${CXX}"

cp $SRC_DIR/scripts/*py $PREFIX/bin
cp $SRC_DIR/scripts/*sh $PREFIX/bin
cp $SRC_DIR/scripts/extract_ref $PREFIX/bin

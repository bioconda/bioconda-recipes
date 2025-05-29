#!/bin/bash

set -xe

pushd build/gmake

make CC=${CC} CFLAGS="-g -pedantic -Wall -I ${SRC_DIR}/include -fPIC ${CFLAGS}"

popd

mkdir -p ${PREFIX}/bin
mkdir -p ${PREFIX}/lib
mkdir -p ${PREFIX}/include

cp ./bin/tidyp ${PREFIX}/bin
cp ./include/* ${PREFIX}/include
cp ./lib/* ${PREFIX}/lib

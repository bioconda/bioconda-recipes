#!/bin/bash

set -xe

mkdir -p ${HOME}/bin
export PATH="${HOME}/bin:$PATH"
ln -s ${CC} ${HOME}/bin/gcc

pushd build/gmake

make CFLAGS="-g -pedantic -Wall -I ${SRC_DIR}/include -fPIC ${CFLAGS}"

popd

mkdir -p ${PREFIX}/bin
mkdir -p ${PREFIX}/lib
mkdir -p ${PREFIX}/include

cp ./bin/tidyp ${PREFIX}/bin
cp ./include/* ${PREFIX}/include
cp ./lib/* ${PREFIX}/lib

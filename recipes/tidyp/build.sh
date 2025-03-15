#!/bin/bash

set -xe

mkdir -p ${HOME}/bin
export PATH="${HOME}/bin:$PATH"

ln -fs ${CC} ${HOME}/bin/gcc

pushd build/gmake
sed -i.bak '85s/^CFLAGS=/CFLAGS=-fPIC/' Makefile
make
popd

mkdir -p ${PREFIX}/bin

cp ./bin/tidyp ${PREFIX}/bin
cp -r ./include ${PREFIX}/
cp -r ./lib ${PREFIX}/

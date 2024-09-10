#!/bin/bash

set -xe

mkdir -p ${HOME}/bin
export PATH="${HOME}/bin:$PATH"
ln -s ${CC} ${HOME}/bin/gcc

pushd build/gmake
make
popd

mkdir -p ${PREFIX}/bin
cp ./bin/tidyp ${PREFIX}/bin

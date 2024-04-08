#!/bin/bash

pushd build/gmake
make
popd

mkdir -p ${PREFIX}/bin
cp ./bin/tidyp ${PREFIX}/bin

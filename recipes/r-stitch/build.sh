#!/usr/bin/env bash

set -xe

mkdir -p $PREFIX/bin 
cp -rf STITCH.R $PREFIX/bin

if [[ $(uname) == "Darwin" ]]; then
    export LDFLAGS=-L${PREFIX}/lib
    ${R} CMD INSTALL --build . --configure-args="CFLAGS=-ferror-limit=0 CXXFLAGS=-ferror-limit=0 -stdlib=libstdc++"
else
    ${R} CMD INSTALL --build .
fi


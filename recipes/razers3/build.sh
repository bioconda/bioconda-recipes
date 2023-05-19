#!/bin/bash

if [ "$(uname)" = 'Darwin' ] ; then
    export MACOSX_DEPLOYMENT_TARGET=10.13 
fi

mkdir -p $PREFIX/bin
mkdir -p build
cd build
cmake .. -DCMAKE_BUILD_TYPE=Release
make razers3
cp bin/razers3 $PREFIX/bin

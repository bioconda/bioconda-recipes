#!/bin/bash

mkdir -p $PREFIX/bin
if [ $(uname -s) = "Darwin" ]; then
    cp bin/razers3 $PREFIX/bin/razers3 && chmod a+x $PREFIX/bin/razers3
else
    mkdir -p build
    cd build
    cmake .. -DCMAKE_BUILD_TYPE=Release
    make razers3
    cp bin/razers3 $PREFIX/bin
fi
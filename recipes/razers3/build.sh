#!/bin/bash

if [ "$(uname)" = 'Darwin' ] ; then
    export CPPFLAGS="${CPPFLAGS//-mmacosx-version-min=10.9/-mmacosx-version-min=10.13}"
fi

mkdir -p $PREFIX/bin
mkdir -p build
cd build
cmake .. -DCMAKE_BUILD_TYPE=Release
make razers3
cp bin/razers3 $PREFIX/bin

#!/bin/bash

if [ $(uname -s) == Darwin ]; then
    # See https://conda-forge.org/docs/maintainer/knowledge_base.html#newer-c-features-with-old-sdk
    export CXXFLAGS="${CXXFLAGS} -D_LIBCPP_DISABLE_AVAILABILITY"
fi
mkdir -p "$PREFIX/bin"
mkdir -p build
cd build
cmake -DLAMBDA_NATIVE_BUILD=0 ..
make
cp bin/lambda3 "$PREFIX/bin/"

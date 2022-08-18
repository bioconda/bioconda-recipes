#!/bin/bash

mkdir -p ${PREFIX}/bin

# add -Wno-narrowing to avoid compilation errors on osx (non-constant-expression cannot be narrowed from type int to size_t) for OSX
if [ "$(uname)" == "Darwin" ]; then
    make -j4 all CC=${CC} CXX=${CXX} CFLAGS="${CXXFLAGS} -Wno-narrowing"
else
    make -j4 all CC=${CC} CXX=${CXX} CFLAGS="${CXXFLAGS}"

# copy binary
chmod +x fxtract
cp fxtract ${PREFIX}/bin/

#!/bin/bash

set -x -e

mkdir -p ${PREFIX}/bin/ bin/
rm -f bin/*

if [ "$(uname)" == "Linux" ]; then
${CXX} -O2 -Wconversion -Wno-sign-conversion -Wno-shorten-64-to-32 -std=c++0x src/scelestial.cc -o bin/scelestial -Wsign-compare
fi

if [ "$(uname)" == "Darwin" ]; then
${CXX} -O2 -Wconversion -Wno-sign-conversion -Wno-shorten-64-to-32 -std=c++0x src/scelestial.cc -o bin/scelestial -Wsign-compare
fi

cp bin/scelestial ${PREFIX}/bin/scelestial

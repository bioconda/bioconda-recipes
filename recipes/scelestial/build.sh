#!/bin/bash

set -x -e

mkdir -p ${PREFIX}/bin/ bin/
rm -f bin/*

if [ "$(uname)" == "Linux" ]; then
${CXX} -O2 -Wconversion -Wno-sign-conversion -Wno-shorten-64-to-32 -std=c++0x src/scelestial.cc -o bin/scelestial -Wsign-compare
${CXX} -o bin/scelestial-synthesis src/synthesis.cc -std=c++11 -Wall -lboost_program_options -I${BUILD_PREFIX}/include -L${BUILD_PREFIX}/lib 
fi

if [ "$(uname)" == "Darwin" ]; then
${CXX} -O2 -Wconversion -Wno-sign-conversion -Wno-shorten-64-to-32 -std=c++0x src/scelestial.cc -o bin/scelestial -Wsign-compare
${CXX} -o bin/scelestial-synthesis src/synthesis.cc -std=c++11 -Wall -lboost_program_options -I${BUILD_PREFIX}/include -L${BUILD_PREFIX}/lib 
fi

cp bin/scelestial ${PREFIX}/bin/scelestial
cp bin/scelestial-synthesis ${PREFIX}/bin/scelestial-synthesis


#!/bin/bash

set -x -e

mkdir -p ${PREFIX}/bin/ build/
rm -f build/*

if [ "$(uname)" == "Linux" ]; then
${CXX} -o build/sankoff src/sankoff.cc -std=c++11 -Wall -lboost_program_options -I${BUILD_PREFIX}/include -L${BUILD_PREFIX}/lib -ltbb
fi

if [ "$(uname)" == "Darwin" ]; then
${CXX} -o build/sankoff src/sankoff.cc -std=c++11 -Wall -lboost_program_options -I${BUILD_PREFIX}/include -L${BUILD_PREFIX}/lib -ltbb
fi

cp build/sankoff ${PREFIX}/bin/sankoff

#!/bin/bash

set -x -e

mkdir -p ${PREFIX}/bin/ build/
rm -f build/*

if [ "$(uname)" == "Linux" ]; then
${CXX} -o build/sankoff src/sankoff-no-dep.cc -std=c++11 -Wall 
fi

if [ "$(uname)" == "Darwin" ]; then
${CXX} -o build/sankoff src/sankoff-no-dep.cc -std=c++11 -Wall 
fi

cp build/sankoff ${PREFIX}/bin/sankoff

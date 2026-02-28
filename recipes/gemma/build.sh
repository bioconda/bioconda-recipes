#!/bin/bash
set -eu

export C_INCLUDE_PATH=${PREFIX}/include
export CPP_INCLUDE_PATH=${PREFIX}/include
export LIBRARY_PATH=${PREFIX}/lib

make release

mkdir -p ${PREFIX}/bin
cp bin/gemma ${PREFIX}/bin/gemma

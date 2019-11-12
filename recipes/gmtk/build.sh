#!/bin/sh

BASE_CC=$(basename $CXX)
DIR_CC=$(dirname $CXX)

PATH="$DIR_CC:$PATH"

./configure --with-cppCmd="$BASE_CC -E -x assembler-with-cpp" --with-logp=table --prefix=$PREFIX
make SHELL='sh -x'
make install

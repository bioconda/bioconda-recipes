#!/bin/bash
set -eu

export C_INCLUDE_PATH=${PREFIX}/include
export LIBRARY_PATH=${PREFIX}/lib

make
make test
mkdir -p ${PREFIX}/bin
cp bin/sambamba ${PREFIX}/bin/sambamba

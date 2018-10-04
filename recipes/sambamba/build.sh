#!/bin/bash
set -eu

export C_INCLUDE_PATH=${PREFIX}/include
export LIBRARY_PATH=${PREFIX}/lib

make
make test
mkdir -p ${PREFIX}/bin
chmod a+x sambamba_v*
cp sambamba_v* ${PREFIX}/bin/sambamba

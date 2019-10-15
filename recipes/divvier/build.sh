#!/bin/bash
set -eu -o pipefail

echo ${PREFIX}
CC=${CC}
CXX=${CXX}
mkdir -p ${PREFIX}/bin
make
cp divvier ${PREFIX}/bin

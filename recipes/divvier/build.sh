#!/bin/bash
set -eu -o pipefail
CPP=$CXX
CC=$CC
echo ${PREFIX}
mkdir -p ${PREFIX}/bin
make
cp divvier ${PREFIX}/bin

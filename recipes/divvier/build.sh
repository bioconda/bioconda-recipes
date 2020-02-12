#!/bin/bash
set -eu -o pipefail
echo ${PREFIX}
mkdir -p ${PREFIX}/bin
make CC=$CC CPP=$CXX
cp divvier ${PREFIX}/bin

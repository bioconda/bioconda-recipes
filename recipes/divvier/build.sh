#!/bin/bash
set -eu -o pipefail
echo ${PREFIX}
mkdir -p ${PREFIX}/bin
make CC="$CC -fcommon" CPP="$CXX -fcommon"
cp divvier ${PREFIX}/bin

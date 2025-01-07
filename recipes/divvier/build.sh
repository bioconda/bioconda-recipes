#!/bin/bash
set -eu -o pipefail

echo ${PREFIX}
mkdir -p ${PREFIX}/bin

make CC="$CC -fcommon" CPP="$CXX -fcommon" -j"${CPU_COUNT}"
install -v -m 0755 divvier ${PREFIX}/bin

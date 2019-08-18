#!/bin/bash
set -eu -o pipefail

./configure
make CC=${CC}
make install

mkdir -p ${PREFIX}/bin
cp bin/svaba ${PREFIX}/bin/

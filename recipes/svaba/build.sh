#!/bin/bash
set -eu -o pipefail

export gcc=${PREFIX}/bin/gcc

./configure
make
make install

mkdir -p ${PREFIX}/bin
cp bin/svaba ${PREFIX}/bin/

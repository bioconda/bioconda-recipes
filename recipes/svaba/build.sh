#!/bin/bash
set -eu -o pipefail

./configure --prefix=$PREFIX
make
mkdir -p $PREFIX/bin
cp bin/svaba $PREFIX/bin

#!/bin/bash
set -eu -o pipefail

mkdir build
cd build
cmake -DCMAKE_CC_COMPILER=$CC -DHTSLIB_DIR=../htslib ..
make

mkdir -p ${PREFIX}/bin
cp bin/svaba ${PREFIX}/bin/

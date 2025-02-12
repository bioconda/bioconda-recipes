#!/bin/bash
set -eu -o pipefail

mkdir build
cd build
cmake ..
make

mkdir -p ${PREFIX}/bin
cp bin/svaba ${PREFIX}/bin/

#!/bin/bash
set -eu -o pipefail

export gcc=${GXX}

echo "DEBUG START"
echo "LOCATION OF GCC:" $(which gcc)
echo "DEBUG END"

./configure
make
make install

mkdir -p ${PREFIX}/bin
cp bin/svaba ${PREFIX}/bin/

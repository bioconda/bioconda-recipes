#!/bin/bash
set -eu -o pipefail

echo "#######################"
echo "### DEBUGGING START ###"
echo "#######################"

find . | grep htslib

echo "#####################"
echo "### DEBUGGING END ###"
echo "#####################"

mkdir build
cd build
cmake -DHTSLIB_DIR=../htslib ..
make

mkdir -p ${PREFIX}/bin
cp bin/svaba ${PREFIX}/bin/

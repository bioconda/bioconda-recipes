#!/bin/bash
set -eu -o pipefail

echo "#######################"
echo "### DEBUGGING START ###"
echo "#######################"

pwd -P

echo ""

find

echo ""

which gcc

echo "#####################"
echo "### DEBUGGING END ###"
echo "#####################"


cmake -DHTSLIB_DIR=htslib
make

mkdir -p ${PREFIX}/bin
cp bin/svaba ${PREFIX}/bin/

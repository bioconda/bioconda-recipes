#!/bin/bash
set -eu -o pipefail

mkdir -p $PREFIX/bin
export CXXFLAGS="${CXXFLAGS} -std=c++14"
mkdir YARA_BUILD
cd YARA_BUILD
cmake .. -DSEQAN_BUILD_SYSTEM=APP:yara
make all

binaries="\
yara_mapper \
yara_indexer \
"

for i in $binaries
do
    cp bin/$i $PREFIX/bin/$i
done

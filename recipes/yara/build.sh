#!/bin/bash
set -eu -o pipefail

mkdir -p $PREFIX/bin

binaries="\
yara_mapper \
yara_indexer \
"

for i in $binaries
do
    cp $SRC_DIR/bin/$i $PREFIX/bin/$i
    chmod a+x $PREFIX/bin/$i
done

#!/bin/sh

mkdir -p $PREFIX/bin

binaries="\
tophat-recondition \
"

PY3_BUILD="${PY_VER%.*}"

for i in $binaries; do cp $i.py $PREFIX/bin/$i && chmod +x $PREFIX/bin/$i; done

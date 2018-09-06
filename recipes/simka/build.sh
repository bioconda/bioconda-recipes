#!/bin/bash
export CPATH=${PREFIX}/include
sh INSTALL

binaries="\
simka \
simkaCount \
simkaCountProcess \
simkaMerge \
"

for i in $binaries; do mv $SRC_DIR/build/bin/$i $PREFIX/bin/$i; done
for i in $binaries; do chmod +x $PREFIX/bin/$i; done
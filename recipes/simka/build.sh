#!/bin/bash

sh INSTALL

binaries = "\
simka \
simkaCount \
simkaCountProcess \
simkaMerge \
"

for i in $binaries; do mv $SRC_DIR/build/bin/$i $PREFIX/bin/$i; done
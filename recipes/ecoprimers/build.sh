#!/bin/bash

mkdir -p $PREFIX/bin

cd src
make

binaries="\
ecoPrimers \
"

for i in $binaries; do cp $i $PREFIX/bin && chmod +x $PREFIX/bin/$i; done


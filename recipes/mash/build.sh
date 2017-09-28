#!/bin/bash


mkdir -p $PREFIX/bin

./bootstrap.sh
./configure --with-capnp=$PREFIX --with-gsl=$PREFIX

make

binaries="\
mash \
"

for i in $binaries; do cp $i $PREFIX/bin && chmod +x $PREFIX/bin/$i; done

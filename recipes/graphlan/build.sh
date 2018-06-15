#!/bin/bash


binaries="graphlan.py graphlan_annotate.py"

mkdir -p $PREFIX/bin

for i in $binaries; do
    cp $i $PREFIX/bin;
done

cp -a src/ $PREFIX/bin

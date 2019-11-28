#!/bin/bash


binaries="export2graphlan.py"

mkdir -p $PREFIX/bin

for i in $binaries; do
    cp $i $PREFIX/bin;
done

# cp -a hclust2/ $PREFIX/bin

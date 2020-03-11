#!/bin/bash


binaries="metaphlan.py strainphlan.py"

mkdir -p $PREFIX/bin

for i in $binaries; do
    cp $i $PREFIX/bin;
done

cp -a utils/*.py $PREFIX/bin
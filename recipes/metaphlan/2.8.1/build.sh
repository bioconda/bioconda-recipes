#!/bin/bash


binaries="metaphlan2.py strainphlan.py"

mkdir -p $PREFIX/bin

for i in $binaries; do
    cp $i $PREFIX/bin;
done

cp -a utils/*.py $PREFIX/bin
cp -a strainphlan_src/*.py $PREFIX/bin

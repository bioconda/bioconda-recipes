#!/bin/bash


binaries="panphlan_map.py panphlan_pangenome_generation.py panphlan_profile.py"

mkdir -p $PREFIX/bin

for i in $binaries; do
    cp $i $PREFIX/bin;
done

cp -a tools/*.sh $PREFIX/bin
cp -a tools/*.py $PREFIX/bin

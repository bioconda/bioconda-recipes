#!/bin/bash

mkdir -p $PREFIX/bin

cd orthofinder

cp orthofinder.py $PREFIX/bin/orthofinder
cp trees_from_MSA.py $PREFIX/bin/trees_from_MSA

chmod a+x $PREFIX/bin/orthofinder $PREFIX/bin/trees_from_MSA

cp -r scripts $PREFIX/bin/

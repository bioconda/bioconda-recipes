#!/bin/bash

mkdir -p $PREFIX/bin

cd orthofinder/

cp orthofinder.py $PREFIX/bin/orthofinder

cp -r scripts $PREFIX/bin/
ln -s ./scripts/trees_from_MSA.py $PREFIX/bin/trees_from_MSA

chmod a+x $PREFIX/bin/orthofinder $PREFIX/bin/scripts/trees_from_MSA.py

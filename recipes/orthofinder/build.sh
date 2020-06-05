#!/bin/bash

mkdir -p $PREFIX/bin

cp orthofinder.py $PREFIX/bin/orthofinder

# scripts_of now contains the config.json file
mkdir $PREFIX/bin/scripts_of
cp -r scripts_of/*py $PREFIX/bin/scripts_of/
cp scripts_of/config.json $PREFIX/bin/scripts_of/config.json

cp -r tools $PREFIX/bin/

chmod a+x $PREFIX/bin/orthofinder

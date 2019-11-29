#!/bin/bash

mkdir -p $PREFIX/bin

cp orthofinder.py $PREFIX/bin/orthofinder

# scripts_of now contains the config.json file
cp -r scripts_of $PREFIX/bin/

cp -r tools $PREFIX/bin/

chmod a+x $PREFIX/bin/orthofinder

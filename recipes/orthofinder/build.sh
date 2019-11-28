#!/bin/bash

mkdir -p $PREFIX/bin

cp orthofinder.py $PREFIX/bin/orthofinder

cp -r scripts_of $PREFIX/bin/

#cp scripts_of/config.json $PREFIX/bin/scripts_of/

cp -r tools $PREFIX/bin/

chmod a+x $PREFIX/bin/orthofinder

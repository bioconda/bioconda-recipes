#!/bin/bash

mkdir -p $PREFIX/bin

cd orthofinder/

cp orthofinder.py $PREFIX/bin/orthofinder

cp -r scripts $PREFIX/bin/

chmod a+x $PREFIX/bin/orthofinder 

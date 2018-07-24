#!/bin/bash

mkdir -p $PREFIX/bin

cd orthofinder/

cp orthofinder.py $PREFIX/bin/orthofinder

cp config.json $PREFIX/bin/

cp -r scripts $PREFIX/bin/

cp -r tools $PREFIX/bin/

chmod a+x $PREFIX/bin/orthofinder

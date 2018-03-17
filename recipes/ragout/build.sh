#!/bin/bash
# creates executables in ./lib/ : ragout-maf2synteny ragout-overlap
make

cp ragout.py $PREFIX/bin/
cp -r ragout $PREFIX/bin/
# copy executables created in ./lib/ to $PREFIX/bin so ragout can find them
cp -r ./lib/ragout-* $PREFIX/bin/

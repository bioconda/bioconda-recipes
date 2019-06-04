#!/bin/bash
mkdir -p $PREFIX/bin
mkdir $PREFIX/lib

cp -r bin/ $PREFIX/
cp -r lib/ $PREFIX/
cp setup.py $PREFIX/

$PYTHON $PREFIX/setup.py install
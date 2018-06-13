#!/bin/bash
mkdir -p $PREFIX/bin
mkdir -p $PREFIX/bin/src/py/
mkdir -p $PREFIX/bin/src/R/

cp src/py/* $PREFIX/bin/src/py/
cp src/R/* $PREFIX/bin/src/R/
ln -s $PREFIX/bin/src/py/valet.py $PREFIX/bin/valet.py

#!/bin/bash

mkdir -p $PREFIX/bin
mkdir -p $PREFIX/opt/mitoz

cp -r * $PREFIX/opt/mitoz/
ln -s $PREFIX/opt/mitoz/MitoZ.py $PREFIX/bin



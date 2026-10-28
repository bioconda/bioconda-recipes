#!/usr/bin/env bash

mkdir -p $PREFIX/bin
mkdir -p $PREFIX/opt/prophane/

cp -r * $PREFIX/opt/prophane/
ln -s $PREFIX/opt/prophane/prophane.py $PREFIX/bin/prophane

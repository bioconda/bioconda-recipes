#!/bin/bash

mkdir -pv $PREFIX/bin
cp -rv clair3 preprocess scripts shared trio $PREFIX/bin
cp clair3.py $PREFIX/bin/
cp run_clair3_trio.sh $PREFIX/bin/

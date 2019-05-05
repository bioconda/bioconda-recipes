#!/bin/bash

make
mkdir -p $PREFIX/bin
mkdir -p $PREFIX/opt/crispritz
chmod 700 -R *
cp crispritz.py $PREFIX/bin
cp buildTST $PREFIX/opt/crispritz
cp searchTST $PREFIX/opt/crispritz
cp searchBruteForce $PREFIX/opt/crispritz
cp -R sourceCode/Python_Scripts/ $PREFIX/opt/crispritz

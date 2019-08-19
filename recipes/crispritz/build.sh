#!/bin/bash

make -f Makefile_conda
mkdir -p $PREFIX/bin
mkdir -p $PREFIX/opt/crispritz
chmod -R 700 .
cp crispritz.py $PREFIX/bin
cp buildTST $PREFIX/opt/crispritz
cp searchTST $PREFIX/opt/crispritz
cp searchBruteForce $PREFIX/opt/crispritz
cp -R sourceCode/Python_Scripts $PREFIX/opt/crispritz

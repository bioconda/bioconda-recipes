#!/bin/bash

make
mkdir -p $PREFIX/bin
chmod 700 -R *
cp crispritz.py $PREFIX/bin
cp buildTST $PREFIX/bin
cp searchTST $PREFIX/bin
cp searchBruteForce $PREFIX/bin
cp -R sourceCode/Python_Scripts/ $PREFIX/bin
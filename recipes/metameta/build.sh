#!/bin/bash
mkdir -p $PREFIX/bin
mkdir -p $PREFIX/opt/metameta/

# Full path to the Snakefile
sed -i "s|Snakefile|$PREFIX/opt/metameta/Snakefile|g" metameta

cp -r * $PREFIX/opt/metameta/
ln -s $PREFIX/opt/metameta/metameta $PREFIX/bin/ 

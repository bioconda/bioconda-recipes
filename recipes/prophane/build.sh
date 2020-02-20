#!/usr/bin/env bash

mkdir -p $PREFIX/bin
mkdir -p $PREFIX/opt/prophane/

# Full path to the Snakefile
#sed -i "s|Snakefile|$PREFIX/opt/metameta/Snakefile|g" metameta

cp -r * $PREFIX/opt/prophane/
ln -s $PREFIX/opt/prophane/prophane $PREFIX/bin/

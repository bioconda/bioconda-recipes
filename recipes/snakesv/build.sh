#!/bin/bash

mkdir -p $PREFIX/bin
mkdir -p $PREFIX/opt/snakeSV/

# Full path to the Snakefile
sed -i "s|workflow/Snakefile|$PREFIX/opt/snakeSV/workflow/Snakefile|g" snakeSV

cp -r * $PREFIX/opt/snakeSV/
ln -s $PREFIX/opt/snakeSV/snakeSV $PREFIX/bin/

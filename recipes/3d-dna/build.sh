#!/bin/bash

this_dir=$(basename $(pwd))
cd ..
mkdir -p $PREFIX/share
cp -r $this_dir $PREFIX/share/3d-dna

mkdir -p $PREFIX/bin
echo "#! /usr/bin/env bash" >> $PREFIX/bin/3d-dna
echo "bash \$(dirname \"\${BASH_SOURCE[0]}\")/../share/3d-dna/run-asm-pipeline.sh \"\$@\"" >> $PREFIX/bin/3d-dna
chmod +x $PREFIX/bin/3d-dna


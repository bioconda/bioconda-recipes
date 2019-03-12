#!/bin/bash
cp CRISPR_Studio_1.0.py $PREFIX/bin
mkdir $PREFIX/bin/tools
cp -r fasta-36.3.8g/ $PREFIX/bin/tools
ln -s  $PREFIX/bin/CRISPR_Studio_1.0.py $PREFIX/bin/CRISPR_Studio
chmod +x $PREFIX/bin/CRISPR_Studio

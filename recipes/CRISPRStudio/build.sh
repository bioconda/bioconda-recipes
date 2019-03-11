#!/bin/bash
cp CRISPR_Studio_1.0.py $PREFIX/bin
cp -r tools/ $PREFIX/bin
ln -s  $PREFIX/bin/CRISPR_Studio_1.0.py $PREFIX/bin/CRISPR_Studio
chmod +x $PREFIX/bin/CRISPR_Studio

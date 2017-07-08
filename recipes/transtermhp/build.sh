#!/usr/bin/env bash

make
mv transterm 2ndscore calibrate.sh make_expterm.py mfold_rna.sh $PREFIX/bin

mkdir -p $PREFIX/data
mv expterm.dat $PREFIX/data

mkdir -p $PREFIX/etc/conda/activate.d/
echo "export TRANSTERMHP=$PREFIX/data/expterm.dat" > $PREFIX/etc/conda/activate.d/transtermhp.sh
mkdir -p $PREFIX/etc/conda/deactivate.d/
echo "unset TRANSTERMHP" > $PREFIX/etc/conda/deactivate.d/transtermhp.sh

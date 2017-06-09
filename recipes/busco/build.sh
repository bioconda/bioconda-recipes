#!/bin/bash

mkdir -p $PREFIX/bin/
cp scripts/BUSCO.py $PREFIX/bin
cp scripts/generate_plot.py $PREFIX/bin

ln -s $PREFIX/bin/BUSCO.py $PREFIX/bin/busco
ln -s $PREFIX/bin/generate_plot.py $PREFIX/bin/generate_plot


#!/bin/bash

mkdir -p $PREFIX/bin/
cp BUSCO.py $PREFIX/bin
cp BUSCO_plot.py $PREFIX/bin
cp generate_plot.py $PREFIX/bin

ln -s $PREFIX/bin/BUSCO.py $PREFIX/bin/busco
ln -s $PREFIX/bin/BUSCO_plot.py $PREFIX/bin/busco_plot
ln -s $PREFIX/bin/generate_plot.py $PREFIX/bin/generate_plot


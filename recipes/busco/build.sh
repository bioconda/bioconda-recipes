#!/bin/bash


mkdir -p $PREFIX/bin/
cp scripts/run_BUSCO.py $PREFIX/bin
cp scripts/generate_plot.py $PREFIX/bin

ln -s $PREFIX/bin/run_BUSCO.py $PREFIX/bin/run_busco
ln -s $PREFIX/bin/generate_plot.py $PREFIX/bin/generate_plot

python setup.py install

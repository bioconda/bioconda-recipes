#!/bin/sh

mkdir -p $PREFIX/bin

# Install the current codebase as an R package
Rscript install.R

# Install executables
install -C exec/smudgeplot.py $PREFIX/bin
install -C exec/smudgeplot_plot.R $PREFIX/bin

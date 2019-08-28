#!/bin/sh

mkdir -p $PREFIX/bin

# Install the current codebase as an R package
Rscript install.R

# PHAST builds multiple binaries
install -C exec/smudgeplot.py $PREFIX/bin
install -C exec/smudgeplot_plot.R $PREFIX/bin

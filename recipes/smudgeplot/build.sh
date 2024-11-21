#!/bin/bash

export CPATH="${PREFIX}/include"

mkdir -p $PREFIX/bin

make -s INSTALL_PREFIX="${PREFIX}" CC="${CC}" -j"${CPU_COUNT}"

# Install executables
install -C exec/smudgeplot.py $PREFIX/bin
install -C exec/hetmers $PREFIX/bin
install -C exec/smudgeplot_plot.R $PREFIX/bin
install -C exec/centrality_plot.R $PREFIX/bin

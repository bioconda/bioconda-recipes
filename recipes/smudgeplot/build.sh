#!/bin/bash

export CPATH="${PREFIX}/include"

mkdir -p "$PREFIX/bin"
mkdir -p exec

make -s INSTALL_PREFIX="${PREFIX}" CC="${CC}" -j"${CPU_COUNT}" install

# Install executables
install -v -m 0755 -C exec/smudgeplot.py "$PREFIX/bin"
install -v -m 0755 -C exec/hetmers "$PREFIX/bin"
install -v -m 0755 -C exec/smudgeplot_plot.R "$PREFIX/bin"
install -v -m 0755 -C exec/centrality_plot.R "$PREFIX/bin"

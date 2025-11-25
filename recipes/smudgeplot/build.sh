#!/bin/bash

export CPATH="${PREFIX}/include"

mkdir -p "$PREFIX/bin"

make -s INSTALL_PREFIX="${PREFIX}" CC="${CC}" -j"${CPU_COUNT}"

# Install executables
install -v -m 0755 -C exec/smudgeplot.py "$PREFIX/bin"
install -v -m 0755 -C exec/hetmers "$PREFIX/bin"
install -v -m 0755 -C exec/smudgeplot_plot.R "$PREFIX/bin"
install -v -m 0755 -C exec/centrality_plot.R "$PREFIX/bin"

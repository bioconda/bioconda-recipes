#!/bin/sh
set -e

# https://github.com/conda-forge/bison-feedstock/issues/7
export M4="${PREFIX}/bin/m4"

make
mkdir -p "$PREFIX/bin"
cp treebest "$PREFIX/bin/"

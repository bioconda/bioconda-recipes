#!/bin/bash

# compile Arriba
make HTSLIB="$PREFIX/lib" CXXFLAGS="-pthread -std=c++0x -O2 -Isource -I$PREFIX/include/htslib -I$PREFIX/include" LDFLAGS="-L$PREFIX/lib -ldl -ldeflate -lz -llzma -lbz2"

# copy executables
mkdir -p "$PREFIX/bin"
cp -pf arriba run_arriba.sh draw_fusions.R "$PREFIX/bin/"

# copy database files
mkdir -p "$PREFIX/var/lib/arriba"
cp -pf database/* download_references.sh "$PREFIX/var/lib/arriba/"


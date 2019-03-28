#!/bin/bash

# compile Arriba
make CPPFLAGS="-I$PREFIX/include -I$PREFIX/include/htslib" LDFLAGS="-L$PREFIX/lib" bioconda

# copy executables
mkdir -p "$PREFIX/bin"
cp -pf arriba run_arriba.sh draw_fusions.R "$PREFIX/bin/"

# copy database files
mkdir -p "$PREFIX/var/lib/arriba"
cp -pf database/* download_references.sh "$PREFIX/var/lib/arriba/"


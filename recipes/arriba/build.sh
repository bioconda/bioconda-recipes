#!/bin/bash

# compile HTSlib and Arriba
make -C htslib-1.8 CPPFLAGS="-DHAVE_LIBDEFLATE -I$PREFIX/include" LDFLAGS="-L$PREFIX/lib" libhts.a
make CXXFLAGS="-pthread -std=c++0x -O2 -Isource -Ihtslib-1.8/htslib -I$PREFIX/include" LDFLAGS="-L$PREFIX/lib -ldeflate -lz -llzma -lbz2"

# copy executables
mkdir -p "$PREFIX/bin"
cp -pf arriba run_arriba.sh draw_fusions.R "$PREFIX/bin/"

# copy database files
mkdir -p "$PREFIX/var/lib/arriba"
cp -pf database/* download_references.sh "$PREFIX/var/lib/arriba/"

